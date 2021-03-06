class User
  attr_accessor :username, :password, :email_address
  attr_writer :banned, :able_to_see_others_bugs

  def banned?
    @banned
  end

  def able_to_see_others_bugs?
    @able_to_see_others_bugs
  end

  def password_matches?(password)
    return false if password.nil?
    return false if password.length == 0

    # note that only first 8 chars are relevant in crypt() :(

    if @password == password.crypt(@password)
      return true
    end

    false
  end

end