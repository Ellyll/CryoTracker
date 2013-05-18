class PlayerDataService
  attr_reader :user_files_directory

  def initialize(user_files_directory)
    unless defined?(user_files_directory) && !user_files_directory.nil?
      raise(ArgumentError, 'must supply path to directory containing the user files')
    end
    unless File.directory?(user_files_directory)
      raise(ArgumentError, 'path that was supplied was not a directory')
    end
    @user_files_directory = user_files_directory
  end

  def get_player_data(username)
    validate_username(username)

    File.open(@user_files_directory + '/' + username).read
  end

  def validate_username(username)
    raise(ArgumentError, 'Must supply username') if username.nil?
    raise(ArgumentError, 'Invalid username format') unless username =~ /^[a-z0-9_]+$/
    filename = @user_files_directory + '/' + username
    raise(ArgumentError, "Non-existant username #{username}") unless File.file?(filename)
  end
end