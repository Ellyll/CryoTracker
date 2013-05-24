require_relative '../models/player'
require_relative '../models/user'

class UserService
  def initialize(player_data_service, player_data_deserialiser)
    raise(ArgumentError, 'Must supply player data service object') if player_data_service.nil?
    raise(ArgumentError, 'Must supply valid player data service object') unless player_data_service.respond_to?(:get_player_data)
    raise(ArgumentError, 'Must supply player data deserialiser object') if player_data_deserialiser.nil?
    raise(ArgumentError, 'Must supply valid player data deserialiser object') unless player_data_deserialiser.respond_to?(:deserialise)

    @player_data_service = player_data_service
    @player_data_deserialiser = player_data_deserialiser
  end

  def get_user(username)
    validate_username(username)

    player_data = @player_data_service.get_player_data(username)
    player = @player_data_deserialiser.deserialise(player_data)

    user = User.new
    user.username = username
    user.email_address = player.strings['finger.email']
    user.banned = player.flags.include?('BugBanned')
    user.able_to_see_others_bugs = see_bugs?(player)

    user
  end

  private

  def see_bugs?(player)
    can_see = false
    level = get_permission_level(player)
    granted = player.granted
    withheld = player.withheld

    if (level >= 23 && !withheld.include?('SeeBugs')) ||
       (level < 23 && granted.include?('SeeBugs'))
      can_see = true
    end

    can_see
  end

  def validate_username(username)
    raise(ArgumentError, 'Must supply username') if username.nil?
    raise(ArgumentError, 'Invalid username format') unless username =~ /^[a-z0-9_]+$/
  end

  def get_permission_level(player)
    level = player.ints['privs']
    if level.nil? || level <= 0
      level = player.ints['level']
      level = level.to_i unless level.nil?
    end

    level = 0 if level.nil?

    level
  end

end
