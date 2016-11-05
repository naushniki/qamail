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
  @session = user_session
  builder :show_session
end

put '/api/create_mailbox' do
  session = user_session
  @mailbox = create_mailbox(session)
  builder :show_mailbox
end

put '/api/create_forwarding_address' do
  body ''
  begin
    session = user_session
    @mailbox = Mailbox.where(:session_id => session.id, :address => params[:address]).first
    forwarding_address = ForwardingAddress.new
    forwarding_address.address = params[:forwarding_address]
    forwarding_address.mailbox_id = @mailbox.id
    forwarding_address.save!
    status 201
  rescue Exception => e
    status 400
  end
end

delete '/api/delete_forwarding_address' do
  body ''
  begin
    session = user_session
    forwarding_address = Mailbox.where(:session_id => session.id, :address => params[:address]).first.ForwardingAddresses.where(:address => params[:address])
    forwarding_address.delete
    status 201
  rescue Exception => e
    status 400
  end
end

get '/api/show_mailbox_content' do
  session = user_session
  @mailbox = Mailbox.where(:session_id => session.id, :address => params[:address]).first
  builder :show_mailbox
end

get '/api/show_letter' do
  user_session.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:letter_id]).first
  cache_control :private, :must_revalidate, :max_age => 31536000
  etag Digest::SHA1.hexdigest(@letter.raw)
  builder :show_letter
end

get '/api/show_rendered_letter' do
  @letter = user_session.mailboxes.where(:address => params[:address]).first.letters.where(:id => params[:letter_id]).first
  @parsed_letter=parse_letter(@letter)
  @parsed_letter.each do |key, value|
    value = Sanitize.clean(value, sanitize_custom_config)
  end
  @letter.raw = @letter.raw.gsub('<', '&lt;').gsub('>', '&gt;')
  cache_control :private, :must_revalidate, :max_age => 31536000
  etag Digest::SHA1.hexdigest(@letter.raw)
  builder :show_rendered_letter
end

delete '/api/empty_mailbox' do
  user_session.mailboxes.where(:address => params[:address]).first.letters.destroy_all
  status 200
  body ''
end
