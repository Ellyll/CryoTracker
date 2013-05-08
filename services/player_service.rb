class PlayerService
  def initialize(user_files_dir)
    unless defined?(user_files_dir) && !user_files_dir.nil?
      raise(ArgumentError, 'must supply path to directory containing the user files')
    end
    unless File.directory?(user_files_dir)
      raise(ArgumentError, 'path that was supplied was not a directory')
    end
    @user_files_dir = user_files_dir
  end

  def get_flags(username)
    validate_username(username)

    flags = Set.new
    file = File.new(get_filename(username), 'r')
    while (line = file.gets)
      if line =~ /^flags /
        flags = flags.merge(line.sub(/^flags /,'').split(' '))
        break
      end
    end
    file.close

    flags
  end

  private

  def validate_username(username)
    raise(ArgumentError, 'Must supply username') if username.nil?
    raise(ArgumentError, 'Invalid username format') unless username =~ /^[a-z0-9_]+$/
    filename = @user_files_dir + '/' + username
    raise(ArgumentError, "Non-existant username #{username}") unless File.file?(filename)
  end

  def get_filename(username)
    @user_files_dir + '/' + username
  end

end
