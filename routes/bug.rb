
get '/bug/' do
  throw(:halt, [400, "Bad Data (No bug id)\n"])
end

get '/bug/:bug_id' do |bug_id|
  @current_user = authenticate!

  throw(:halt, [400, "Bad Data (No bug id)\n"]) if bug_id.nil? || bug_id == ''
  throw(:halt, [400, "Bad Data (Invalid bug id)\n"]) unless bug_id =~ /^\d+$/

  bug = Bug.get(bug_id)
  throw(:halt, [404, "Not Found (No such bug id)\n"]) if bug.nil?

  unless @current_user.able_to_see_others_bugs? ||
         bug.user == @current_user.username
    throw(:halt, [403, "Forbidden (Cannot see bug)\n"])
  end

  @title = "#{Config::APP[:name]} - Bug #{bug_id}"
  @bug = bug
  haml :view_bug
end