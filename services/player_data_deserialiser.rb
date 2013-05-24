require_relative '../models/player'

class PlayerDataDeserialiserError < Exception
end

class PlayerDataDeserialiser

  def deserialise(player_data)
    index = 0
    index, header_type, header_name = read_header(player_data,index)

    unless header_type == 'mudobject'
      raise(PlayerDataDeserialiserError, 'mudobject not found for header')
    end

    index, flags, granted, withheld, missions, strings, ints = read_body(player_data, index)

    player = Player.new
    player.username = header_name
    player.flags = flags
    player.granted = granted
    player.withheld = withheld
    player.missions = missions
    player.strings = strings
    player.ints = ints

    player
  end

  #private

  def read_header(player_data, index)
    # read header type
    header_type = ''
    until player_data[index] =~ /\s/ do
      header_type += player_data[index]
      index += 1
    end

    if player_data[index] == "\n"
      raise(PlayerDataDeserialiserError, 'Newline found while reading header type')
    end

    # skip whitespace
    index = skip_whitespace(player_data, index)

    # read header name
    index, header_name = read_string_value(player_data, index)

    # skip until after {
    until player_data[index] == '{' || index == player_data.length - 1 do
      index += 1
    end
    if index == player_data.length - 1 || player_data[index] != '{'
      raise(PlayerDataDeserialiserError, 'Could not find opening { while reading header')
    end
    index += 1

    index = skip_whitespace(player_data, index)

    return index, header_type, header_name
  end

  def read_body(player_data, index)
    flags = Set.new
    granted = Set.new
    withheld = Set.new
    missions = Set.new
    strings = {}
    ints = {}

    index = skip_whitespace(player_data, index)
    until player_data[index] == '}' || index >= player_data.length do
      index, data_type = read_data_type(player_data, index)

      case data_type
        when 'flags'
          index, flags = read_flags(player_data, index)
        when 'granted'
          index, granted = read_flags(player_data, index)
        when 'withheld'
          index, withheld = read_flags(player_data, index)
        when 'mission'
          index, missions = read_flags(player_data, index)
        when 'string'
          index, string_name, string_value = read_string(player_data, index)
          strings[string_name] = string_value
        when 'int'
          index, int_name, int_value = read_int(player_data, index)
          ints[int_name] = int_value
        else
          raise(PlayerDataDeserialiserError, "unrecognised data type #{data_type} at index #{index}")
      end

      index = skip_whitespace(player_data, index)
    end

    return index, flags, granted, withheld, missions, strings, ints
  end

  def read_flags(player_data, index)
    flags = Set.new
    until player_data[index] == "\n" do
      name = ''
      until player_data[index] =~ /\s/ do
        name += player_data[index]
        index += 1
      end
      if name.length == 0
        raise(PlayerDataDeserialiserError, "unexpected empty name while reading flags at index=#{index}")
      end
      flags.add(name)
      index = skip_whitespace_except_newline(player_data, index)
    end

    return index, flags
  end

  def read_string(player_data, index)
    index, name = read_name(player_data, index)
    index = skip_whitespace_except_newline(player_data, index)

    index, value = read_string_value(player_data, index)
    index = skip_whitespace_except_newline(player_data, index)

    return index, name, value
  end

  def read_int(player_data, index)
    index, name = read_name(player_data, index)
    index = skip_whitespace_except_newline(player_data, index)

    index, value = read_int_value(player_data, index)
    index = skip_whitespace_except_newline(player_data, index)

    return index, name, value
  end


  def read_data_type(player_data, index)
    index, data_type = read_name(player_data, index)

    index = skip_whitespace_except_newline(player_data, index)

    return index, data_type
  end

  def read_name(player_data, index)
    name = ''

    until player_data[index] =~ /\s/ do
      name += player_data[index]
      index += 1
    end

    if name.nil? || name.length == 0
      raise(PlayerDataDeserialiserError, 'name not read')
    end

    return index, name
  end

  def read_string_value(player_data, index)
    # skip quote
    unless player_data[index] == '"'
      raise(PlayerDataDeserialiserError, 'Double-quotes not found while reading string value')
    end
    index += 1

    string_value = ''
    while true do
      if player_data[index] == "\\" # if backslash, read the next char
        if index == player_data.length - 1
          raise(PlayerDataDeserialiserError, 'Closing quote not found while reading header name')
        end
        string_value += player_data[index+1]
        index += 2
        next
      elsif player_data[index] == '"' # got a quote - finished reading
        index += 1
        break
      else
        string_value += player_data[index]
        index += 1
      end
    end
    return index, string_value
  end

  def read_int_value(player_data, index)
    int_string = ''
    while player_data[index] =~ /[\-\d]/ do
      int_string += player_data[index]
      index += 1
    end
    index = skip_whitespace_except_newline(player_data, index)
    unless player_data[index] == "\n"
      raise(PlayerDataDeserialiserError, "unexpected character while reading int value at index #{index}")
    end
    if int_string.length == 0
      raise(PlayerDataDeserialiserError, "nothing found while reading int value at index #{index}")
    end
    index += 1 # skip newline

    int_value = int_string.to_i

    return index, int_value
  end

  def skip_whitespace(player_data, index)
    while player_data[index] =~ /\s/ do
      index += 1
    end
    index
  end

  def skip_whitespace_except_newline(player_data, index)
    while player_data[index] =~ /[ \t\r\f]/ do
      index += 1
    end
    index
  end

end
