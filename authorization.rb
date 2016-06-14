def user_session
  session = Session.find_by(:session_key => self.params[:session_key])
  if session == nil
    session = Session.find_by(:session_key => self.request.cookies['session_key'])
  end
  if Time.now - session.last_visit > 60*60
    session.last_visit = Time.now
    session.save
  end
  return session
end
