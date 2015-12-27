require './base.rb'
require './api.rb'
require './notify.rb'
require 'digest/sha1'
require 'sanitize'
require './extra_mail_tools.rb'
require './authorization.rb'
include ExtraMailTools

sanitize_custom_config = Sanitize::Config.merge(Sanitize::Config::RELAXED,
                                                {:elements => (Sanitize::Config::RELAXED[:elements] + ['font', 'center']),
                                                 :add_attributes =>  {'a' => {'target' => '_blank'}}})

class QAMail < Sinatra::Base
  helpers Sinatra::Streaming
end

set :public_folder, 'static'

before do
  cache_control :private, :must_revalidate, :max_age => 0
end

class Mailbox
  def etag
    digest = String.new
    if f = self.letters.order(id: :desc).first then
      digest << f.subject.to_s
      digest << f.written_at.to_s
      digest << f.from.to_s
      digest << self.previous_mailbox_address.to_s
      digest << self.next_mailbox_address.to_s
      digest << self.address.to_s
      return  Digest::SHA1.hexdigest(digest)
    else
      digest << self.previous_mailbox_address.to_s
      digest << self.next_mailbox_address.to_s
      digest << self.address.to_s
      return Digest::SHA1.hexdigest(digest)
    end
  end

  def previous_mailbox_address
    session = self.session
    mailboxes = session.mailboxes.order(id: :asc)
    mailbox_index = mailboxes.find_index { |mailbox| mailbox.address == self.address }
    if mailbox_index == 0 then return nil
    else
      return mailboxes[mailbox_index - 1].address
    end
  end

  def next_mailbox_address
    session = self.session
    mailboxes = session.mailboxes.order(id: :asc)
    mailbox_index = mailboxes.find_index { |mailbox| mailbox.address == self.address }
    if (a = mailboxes[mailbox_index + 1]) == nil then return nil
    else
      return a.address
    end
  end
end

def create_mailbox(session)
  mailbox = Mailbox.new
  mailbox.session_id = session.id
  mailbox.address = String.new
  7.times{mailbox.address << [('0'..'9'),('a'..'z')].map{ |i| i.to_a }.flatten.sample}
  mailbox.address << "@" << $settings['domain']
  mailbox.save
  return mailbox
end

def create_session
  session = Session.new
  session.session_key = String.new
  24.times{session.session_key << [('0'..'9'),('A'..'Z'),('a'..'z')].map{ |i| i.to_a }.flatten.sample}
  session.save
  return session
end

get '/show_mailbox' do
  @mailbox = user_session.mailboxes.where(:address => params[:address]).first
  if @mailbox == nil then
    status 404
    erb :oops
  else
    @letters = Letter.where(:mailbox_id => @mailbox.id).order(written_at: :desc).select([:id, :from, :subject, :written_at])

    #Protect from XSS in letter subject
    @letters.each do |letter|
      if letter.subject != nil
        letter.subject = letter.subject.to_s.gsub('<', '&lt;').gsub('>', '&gt;')
      end
    end

    etag @mailbox.etag
    erb :show_mailbox
  end
end

get '/show_letter' do
  @letter = user_session.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:id]).first
  @letter.subject = @letter.subject.to_s.gsub('<', '&lt;').gsub('>', '&gt;')
  @session_key = params[:session_key]
  @address = params[:address]
  if defined? params[:no_header]
    @render_header = false
  else
    @render_header = true
  end
  if @letter == nil then
    status 404
    erb :oops
  else
    parsed_letter = Mail.read_from_string(@letter.raw)
    if parsed_letter.parts.count == 0
      if parsed_letter.content_type.include? 'text/html' and params[:prefer_text]!='yes'
        @body = parsed_letter.body.decoded
      elsif parsed_letter.content_type.include? 'text/plain'
        @is_plain_text=true
        @body = parsed_letter.body.decoded
      end
      encoding=detect_letter_encoding(parsed_letter)
      if encoding==nil
        encoding='utf-8' #If we cannot detect encoding, we assume it's UTF-8
      end
    else
      parsed_letter.parts.each do |part|
        if part.content_type.include?'text/html' and params[:prefer_text]!='yes'
          @body = part.body.decoded
          @is_plain_text=false
        elsif (part.content_type.include?'text/plain')
          if @body == nil
            @body = part.body.decoded
            @is_plain_text=true
          end
          @plain_text_available = true
        end
        encoding=detect_part_encoding(part)
        if encoding==nil
          encoding='utf-8' #If we cannot detect encoding, we assume it's UTF-8
        end
      end
    end
    if @body
      @body.force_encoding encoding
      @body = Sanitize.clean(@body, sanitize_custom_config)
    end
    cache_control :private, :must_revalidate, :max_age => 31536000
    etag Digest::SHA1.hexdigest(@letter.raw)
    erb :show_letter, :layout => :no_css
  end
end

get '/show_raw_letter' do
  @letter = user_session.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:id]).first
  if @letter == nil then
    status 404
    erb :oops
  else
  @letter.raw = @letter.raw.gsub('<', '&lt;').gsub('>', '&gt;')
  cache_control :private, :must_revalidate, :max_age => 31536000
  etag Digest::SHA1.hexdigest(@letter.raw)
  erb :show_raw_letter
  end
end

get '/show_session' do
  session = user_session
  @newest_mailbox = session.mailboxes.last
  @session_key = session.session_key
  erb :show_session
end

get '/new_session' do
  session = create_session
  create_mailbox(session)
  response.set_cookie "session_key", {:value => session.session_key, :domain => $settings['domain'], :expires => (Time.now + 60*60*24*365*10)}
  redirect "/"
end

get '/new_mailbox' do
  session = user_session
  create_mailbox(session)
  redirect "/"
end

get '/' do
  @session=user_session
  if @session!=nil
    erb :"/new/main", :layout => nil
  else
    redirect '/new_session'
  end
end

get '/old_ui' do
  session=user_session
  if session!=nil
    @newest_mailbox = session.mailboxes.last
    @session_key = session.session_key
    erb :show_session
  else
    redirect '/new_session'
  end
end

get '/empty_mailbox' do
  user_session.mailboxes.where(:address => params[:address]).first.letters.destroy_all
  redirect "/show_mailbox?session_key=#{params[:session_key]}&address=#{params[:address]}"
end

get '/reply_to_letter' do
  begin
    @letter = user_session.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:id]).first
  rescue
    status 404
    erb :oops
    break
  end
  @mailbox = @letter.mailbox
  @to = @letter.from
  @reply_text='Placeholder reply text'
  erb :reply_to_letter
end

post '/send_reply' do

  mailbox = user_session.mailboxes.where(:address => params[:from_address]).first
  if mailbox == nil then
    status 404
    erb :oops
    break
  end

  letter_file = Mail.new(
    :sender => (params[:senders_name].to_s + ' <' + mailbox.address + '>'),
    :to => params[:to],
    :CC => params[:CC],
    :subject => params[:subject],
    :body => params[:message]
  )

  letter = OutgoingLetter.new
  letter.mailbox_id=mailbox.id
  letter.from = letter_file.from
  letter.subject = letter_file.subject
  letter.to = letter_file.to.join(',')
  letter.written_at = Time.now
  letter.raw=letter_file.to_s
  letter.save

  redirect "/show_letter?id=#{mailbox.letters.last.id}&address=#{mailbox.address}"

end
