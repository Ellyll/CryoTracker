helpers do

  def protected!
    unless authorised?
      response['WWW-Authenticate'] = "Basic realm=\"#{Config::APP[:name]}\""
      throw(:halt, [401, "Not authorised\n"])
    end
  end

  def authorised?
    as = AuthenticationService.new(Config::AUTHENTICATION[:user_files_directory])
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    if @auth.provided? && @auth.basic? && @auth.credentials
      username = @auth.credentials[0]
      password = @auth.credentials[1]
      return as.is_authenticated?(username, password)
    end
    false
  end

end