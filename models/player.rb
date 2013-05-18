class Player
  attr_accessor :username, :email_address
  attr_writer :banned, :able_to_see_others_bugs

  def banned?
    @banned
  end

  def able_to_see_others_bugs?
    @able_to_see_others_bugs
  end

end