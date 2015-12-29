require 'sanitize'

sanitize_custom_config = Sanitize::Config.merge(Sanitize::Config::RELAXED,
                                                {:elements => (Sanitize::Config::RELAXED[:elements] + ['font', 'center']),
                                                 :add_attributes =>  {'a' => {'target' => '_blank'}}})

put '/api/create_session' do
  @session = create_session
  create_mailbox(@session)
  builder :show_session
end

get '/api/list_mailboxes' do
  @session = Session.where(:session_key => params[:session_key]).first
  builder :show_session
end

put '/api/create_mailbox' do
  session = Session.where(:session_key => params[:session_key]).first
  @mailbox = create_mailbox(session)
  builder :show_mailbox
end

get '/api/show_mailbox_content' do
  session = Session.where(:session_key => params[:session_key]).first
  @mailbox = Mailbox.where(:session_id => session.id, :address => params[:address]).first
  builder :show_mailbox
end

get '/api/show_letter' do
  @letter = Session.where(:session_key => params[:session_key]).first.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:letter_id]).first
  cache_control :private, :must_revalidate, :max_age => 31536000
  etag Digest::SHA1.hexdigest(@letter.raw)
  builder :show_letter
end

get '/api/show_rendered_letter' do
  @letter = Session.where(:session_key => params[:session_key]).first.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:letter_id]).first
  @parsed_letter=parse_letter(@letter)
  @parsed_letter.each do |key, value|
    value = Sanitize.clean(value, sanitize_custom_config)
  end
  cache_control :private, :must_revalidate, :max_age => 31536000
  etag Digest::SHA1.hexdigest(@letter.raw)
  builder :show_rendered_letter
end

delete '/api/empty_mailbox' do
  Session.where(:session_key => params[:session_key]).first.mailboxes.where(:address => params[:address]).first.letters.destroy_all
  status 200
  body ''
end
