def user_session
  session = Session.find_by(:session_key => self.params[:session_key])
  if session == nil
    session = Session.find_by(:session_key => self.request.cookies['session_key'])
  end
  if session != nil
    if Time.now.to_i - session.last_visit.to_i > 60*60
      session.last_visit = Time.now
      session.save
    end
  end
  return session
end
