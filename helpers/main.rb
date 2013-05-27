require 'open-uri'
require_relative '../services/player_data_service'
require_relative '../services/player_data_deserialiser'
require_relative '../services/user_service'

helpers do

  def authenticate!
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    if @auth.provided? && @auth.basic? && @auth.credentials
      username = @auth.credentials[0]
      password = @auth.credentials[1]
    else
      not_authorised!
    end

    if username.nil? ||
       username.empty? ||
       password.nil? ||
       password.empty?
      not_authorised!
    end

    if ((defined? settings) && settings.environment == :test) || ENV['RACK_ENV'] == 'test'
      user_files_directory = Config::TEST[:user_files_directory]
    else
      user_files_directory = Config::AUTHENTICATION[:user_files_directory]
    end
    player_data_service = PlayerDataService.new(user_files_directory)
    player_data_deserialiser = PlayerDataDeserialiser.new()
    user_service = UserService.new(player_data_service, player_data_deserialiser)

    begin
      user = user_service.get_user(username)
    rescue ArgumentError # user not found
      user = nil
    end

    not_authorised! if user.nil?
    not_authorised! unless user.password_matches?(password)
    banned! if user.banned?

    user
  end

  def not_authorised!
    response['WWW-Authenticate'] = "Basic realm=\"#{Config::APP[:name]}\""
    throw(:halt, [401, "Not authorised\n"])
  end

  def banned!
    throw(:halt, [403, "Forbidden (Banned)\n"])
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