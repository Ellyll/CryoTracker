
class AuthenticationService

  def initialize(user_files_dir)
    @user_files_dir = user_files_dir
  end

  def is_authenticated?(username,password)
    saved_hash = get_saved_hash(username)
    if saved_hash == nil then
      return false
    end
    new_hash = password.crypt(saved_hash)
    if saved_hash == new_hash then
      return true
    else
      return false
    end
  end

  private
  
  def get_saved_hash(username)
    filename = @user_files_dir + "/" + username
    saved_hash = ''
    if !File.exists? filename then
      return nil
    end
    File.open(filename, "r").each_line do |line|
      if line =~ /password/ then
        saved_hash = line.strip.sub(/string password "([^"]+)"/, "\\1")
        return saved_hash
      end
    end

    return nil
  end
end

