module QamailAuthorization

  def user_session(request)
    begin
      return Session.find_by(:session_key => request.cookies['session_key'])
    rescue
      return Session.find_by(:session_key => request.params[:session_key])
    rescue
      return nil
    end
  end

end
