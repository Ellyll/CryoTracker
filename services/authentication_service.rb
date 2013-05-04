
class AuthenticationService

  def initialize(user_files_dir)
    @user_files_dir = user_files_dir
  end

  def is_authenticated?(username,password)
    unless username =~ /^[a-z0-9]+$/
      return false
    end
    saved_hash = get_saved_hash(username)
    if saved_hash == nil then
      return false
    end

    saved_hash == password.crypt(saved_hash)
  end

  private
  
  def get_saved_hash(username)
    filename = @user_files_dir + '/' + username
    unless File.exists? filename
      return nil
    end
    File.open(filename, 'r').each_line do |line|
      if line =~ /password/
        saved_hash = line.strip.sub(/string password "([^"]+)"/, "\\1")
        return saved_hash
      end
    end

    nil
  end
end

