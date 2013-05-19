require_relative '../models/player'

class PlayerService
  def initialize(player_data_service)
    raise(ArgumentError, 'Must supply player data service') if player_data_service.nil?
    raise(ArgumentError, 'Must supply valid player data service object') unless player_data_service.respond_to?(:get_player_data)
    @player_data_service = player_data_service
  end

  def get_player(username)
    validate_username(username)

    player = Player.new
    player.username = username
    player.email_address = get_email(username)
    player.banned = banned?(username)
    player.able_to_see_others_bugs = see_bugs?(username)

    player
  end

  def get_flags(username)
    validate_username(username)

    get_generic_flags('flags', username)
  end

  def get_email(username)
    validate_username(username)

    email = nil

    lines = @player_data_service.get_player_data(username).split(/\n/)
    lines.each do |line|
      if line =~ /^string finger.email ".+"$/
        email = line.sub(/^string finger.email "(.+)"$/,'\1')
        break
      end
    end

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

  def banned?(username)
    get_flags(username).include?('BugBanned')
  end

  def validate_username(username)
    raise(ArgumentError, 'Must supply username') if username.nil?
    raise(ArgumentError, 'Invalid username format') unless username =~ /^[a-z0-9_]+$/
  end

  def get_generic_flags(type, username)
    flags = Set.new

    lines = @player_data_service.get_player_data(username).split(/\n/)
    lines.each do |line|
      if line =~ /^#{type} /
        flags = flags.merge(line.sub(/^#{type} /,'').split(' '))
        break
      end
    end

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

    lines = @player_data_service.get_player_data(username).split(/\n/)
    lines.each do |line|
      if line =~ /^int #{attribute} \d+.*$/
        value = line.sub(/^int #{attribute} (\d+).*$/,'\1')
        break
      end
    end
    value = value.to_i unless value.nil?

    value
  end

end
