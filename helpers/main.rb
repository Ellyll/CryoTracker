require 'open-uri'

helpers do

  def protected!
    unless authorised?
      response['WWW-Authenticate'] = "Basic realm=\"#{Config::APP[:name]}\""
      throw(:halt, [401, "Not authorised\n"])
    end

    if banned?
      throw(:halt, [403, "Forbidden (Banned)\n"])
    end
  end

  def authorised?
    if ((defined? settings) && settings.environment == :test) || ENV['RACK_ENV'] == 'test'
      user_files_directory = Config::TEST[:user_files_directory]
    else
      user_files_directory = Config::AUTHENTICATION[:user_files_directory]
    end
    as = AuthenticationService.new(user_files_directory)
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    if @auth.provided? && @auth.basic? && @auth.credentials
      username = @auth.credentials[0]
      password = @auth.credentials[1]
      return as.is_authenticated?(username, password)
    end
    false
  end

  def banned?
    if ((defined? settings) && settings.environment == :test) || ENV['RACK_ENV'] == 'test'
      user_files_directory = Config::TEST[:user_files_directory]
    else
      user_files_directory = Config::AUTHENTICATION[:user_files_directory]
    end

    username = @auth.credentials[0]

    player_service = PlayerService.new(user_files_directory)
    player = player_service.get_player(username)

    player.banned?
  end

  def get_page(page_param)
    if page_param
      page = (page_param.to_i) -1
      page = 0 if page < 0
    else
      page = 0
    end
    page
  end

  def get_page_size(page_size_param)
    default_size = Config::APP[:default_page_size]
    default_size ||= 30
    if page_size_param
      page_size = (page_size_param.to_i)
      page_size = default_size if page_size < 1
    else
      page_size = default_size
    end
    page_size
  end

  def build_url(stem, options)
    url = stem
    first_item = true
    options.each do |key,value|
      if value
        url += first_item ? '?' : '&'
        url += URI::encode(key.to_s) + '=' + URI::encode(value)
        first_item = false
      end
    end

    url
  end

end