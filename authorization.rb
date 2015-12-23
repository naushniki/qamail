def user_session(request, params)
  session = Session.find_by(:session_key => params[:session_key])
  if session != nil
    return session
  else
    session = Session.find_by(:session_key => request.cookies['session_key'])
    return session
  end
end
