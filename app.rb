require 'rubygems'
require 'sinatra'
require 'haml'

require 'config'
require 'models/bugs'
require 'models/authentication_service'
require 'view_models/bug_list_item_view_model'

helpers do

  def protected!
    unless authorised?
      response['WWW-Authenticate'] = 'Basic realm="CryoTracker"'
      throw(:halt, [401, "Not authorised\n"])
    end
  end

  def authorised?
    as = AuthenticationService.new(Config::AUTHENTICATION[:user_files_directory])
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    if @auth.provided? && @auth.basic? && @auth.credentials
      username = @auth.credentials[0]
      password = @auth.credentials[1]
      return as.is_authenticated?(username, password)
    end
    false
  end

end

get '/' do
  protected!
  #TODO: check if user is banned
  if params[:page]
    page = (params[:page].to_i) -1
    page = 0 if page < 0
  else
    page = 0
  end
  page_size = 30

  columns_available = {
                        'bug_id.desc' => :bug_id.desc,
                        'state.desc' => :current_state_name.desc,
                        'last_changed.desc' => :last_changed.desc,
                        'reported_by.desc' => :reported_by.desc,
                        'component.desc' => [ :component_1_name.desc, :component_2.desc ],
                        'severity.desc' => :current_severity_name.desc,
                        'last_changed_by.desc' => :last_changed_by.desc
                      }
  order = []
  if params[:order]
    order_wanted = params[:order]
    order_wanted.each do |column|
      order.push(columns_available[column]) if columns_available.has_key?(column)
    end
    order = order.flatten()
  end
  order = [ :last_changed.desc ] if order.count == 0

  @bugs = BugList.all(
                      :current_state_id => [1,2],
                      :limit => page_size,
                      :offset => page*page_size,
                      :order => order
                     )

  # map model to view model bugs
  @bugs = @bugs.map do |bug|
    item = BugListItemViewModel.new
    item.bug_id = bug.bug_id
    item.comment_count = bug.comment_count
    item.current_state_name = bug.current_state_name
    item.current_severity_colour = bug.current_severity_colour
    item.last_changed = bug.last_changed
    item.description = bug.description
    item.reported_by = bug.reported_by
    item.component = bug.component_1_name
    if bug.component_2.length >  0
      item.component += ':' + bug.component_2
    end
    item.severity_name = bug.current_severity_name
    item.last_change_by = bug.last_changed_by
    item
  end

  # TODO: check for html encoding
  haml :index
end
