require './base.rb'

get '/static/:file' do
  send_file('./static/'+params[:file])
end

get '/favicon.ico' do
  send_file('./static/favicon.ico')
end

get '/show_mailbox' do
  session = Session.where(:session_key => params[:session_key]).first
  if session == nil then status 404
  else
    mailbox = session.mailboxes.where(:address => params[:address]).first
    if mailbox == nil then status 404
    else
      @letters = Letter.where(:mailbox_id => mailbox.id).order(written_at: :desc)
      @session_key = params[:session_key]
      erb :show_mailbox
    end
  end 
end