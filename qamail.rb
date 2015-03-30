require './base.rb'

def create_mailbox(session)
  mailbox = Mailbox.new
  mailbox.session_id = session.id
  mailbox.address = String.new
  7.times{mailbox.address << [('0'..'9'),('a'..'z')].map{ |i| i.to_a }.flatten.sample}
  mailbox.address << "@" << $settings['domain']
  mailbox.save
end

get '/static/:file' do
  send_file('./static/'+params[:file])
end

get '/favicon.ico' do
  send_file('./static/favicon.ico')
end

get '/show_mailbox' do
  session = Session.where(:session_key => params[:session_key]).first
  if session == nil then
    status 404
    erb :oops
  else
    mailbox = session.mailboxes.where(:address => params[:address]).first
    if mailbox == nil then
      status 404
      erb :oops
    else
      @letters = Letter.where(:mailbox_id => mailbox.id).order(written_at: :desc)
      @session_key = params[:session_key]
      @mailbox = mailbox
      erb :show_mailbox
    end
  end
end

get '/show_letter' do
  @letter = Session.where(:session_key => params[:session_key]).first.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:id]).first
  @session_key = params[:session_key]
  @address = params[:address]
  if @letter == nil then
    status 404
    erb :oops
  else
    parsed_letter = Mail.read_from_string(@letter.raw)
    @body = parsed_letter.body.decoded
    parsed_letter.parts.each do |part|
      if part.content_type.include?'text/html'
        @body = part.body.decoded
      elsif (part.content_type.include?'text/plain' and @body == nil)
        @body = part.body.decoded
      end
    end
    @body = @body.force_encoding 'utf-8'
    erb :show_letter
  end
end

get '/show_raw_letter' do
  @letter = Session.where(:session_key => params[:session_key]).first.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:id]).first
  if @letter == nil then
    status 404
    erb :oops
  else
  erb :show_raw_letter
  end
end

get '/show_session' do
  @newest_mailbox = Session.where(:session_key => params[:session_key]).first.mailboxes.last
  @session_key = params[:session_key]
  erb :show_session
end

get '/new_session' do
  session = Session.new
  session.session_key = String.new
  24.times{session.session_key << [('0'..'9'),('A'..'Z'),('a'..'z')].map{ |i| i.to_a }.flatten.sample}
  session.save
  create_mailbox(session)
  redirect "/show_session?session_key=#{session.session_key}"
end

get '/new_mailbox' do
  session = Session.where(:session_key => params[:session_key]).first
  create_mailbox(session)
  redirect "/show_session?session_key=#{session.session_key}"
end

get '/' do
  redirect '/new_session'
end
