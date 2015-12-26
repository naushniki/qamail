def user_session
  session = Session.find_by(:session_key => self.params[:session_key])
  if session != nil
    return session
  else
    session = Session.find_by(:session_key => self.request.cookies['session_key'])
    return session
  end
end
