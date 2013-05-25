require_relative '../models/player'

class PlayerDataSerialiser

  # @param [Player] player
  # @return [String] player_data
  def serialise(player)
    raise(ArgumentError, 'must supply a Player object') if player.nil?
    raise(ArgumentError, 'supplied object was not of type Player') unless player.kind_of?(Player)

    player_data = "mudobject #{player.username} {\n"

    player_data += serialise_flags(player.flags, 'flags')
    player_data += serialise_flags(player.granted, 'granted')
    player_data += serialise_flags(player.withheld, 'withheld')
    player_data += serialise_flags(player.missions, 'mission')
    player_data += serialise_strings(player.strings)
    player_data += serialise_ints(player.ints)

    player_data += "}\n"

    player_data
  end

  private

  def serialise_flags(flags, flag_type)
    return '' if flags.nil?

    str = flags.to_a.join(' ')
    str = ' ' + str if str.length > 0

    "#{flag_type}#{str}\n"
  end

  def serialise_strings(strings)
    return '' if strings.nil?

    str = ''
    strings.each do |key,value|
      v = value.gsub(/"/, '\\"') # escape double-quotes
      str += "string #{key} \"#{v}\"\n"
    end

    str
  end

  def serialise_ints(ints)
    return '' if ints.nil?

    str = ''
    ints.each do |key,value|
      str += "int #{key} #{value}\n"
    end

    str
  end

end