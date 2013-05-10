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

    get_generic_flags('flags', username)
  end

  def get_email(username)
    validate_username(username)

    email = nil
    file = File.new(get_filename(username), 'r')
    while (line = file.gets)
      if line =~ /^string finger.email ".+"$/
        email = line.sub(/^string finger.email "(.+)"$/,'\1').chomp
        break
      end
    end
    file.close

    email
  end

  def see_bugs?(username)
    validate_username(username)

    can_see = false
    level = get_permission_level(username)
    granted = get_granted_flags(username)
    withheld = get_withheld_flags(username)

    if (level >= 23 && !withheld.include?('SeeBugs')) ||
       (level < 23 && granted.include?('SeeBugs'))
      can_see = true
    end

    can_see
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

  def get_generic_flags(type, username)
    flags = Set.new
    file = File.new(get_filename(username), 'r')
    while (line = file.gets)
      if line =~ /^#{type} /
        flags = flags.merge(line.sub(/^#{type} /,'').split(' '))
        break
      end
    end
    file.close

    flags
  end

  def get_granted_flags(username)
    get_generic_flags('granted', username)
  end

  def get_withheld_flags(username)
    get_generic_flags('withheld', username)
  end

  def get_permission_level(username)
    level = get_int_value('privs', username)
    if level.nil? || level <= 0
      level = get_int_value('level', username)
      level = level.to_i unless level.nil?
    end

    level = 0 if level.nil?

    level
  end

  def get_int_value(attribute, username)
    value = nil
    file = File.new(get_filename(username), 'r')
    while (line = file.gets)
      if line =~ /^int #{attribute} \d+.*$/
        value = line.sub(/^int #{attribute} (\d+).*$/,'\1').chomp
        break
      end
    end
    file.close

    value = value.to_i unless value.nil?

    value
  end

end
