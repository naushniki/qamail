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
  builder :show_letter
end

delete '/api/empty_mailbox' do
  Session.where(:session_key => params[:session_key]).first.mailboxes.where(:address => params[:address]).first.letters.destroy_all
  status 200
  body ''
end
