
# @param bugs [Array<Bug>] A list of Bug objects
# @return [Array<BugListViewModelItem>] A list of BugListViewModelItem objects
def map_bug_list_to_view_model(bugs)
  bugs.map do |bug|
    item = BugListItemViewModel.new
    item.bug_id = bug.bug_id
    item.comment_count = bug.comment_count
    item.state_name = bug.current_state_name
    item.current_severity_colour = bug.current_severity_colour
    item.last_changed = bug.last_changed
    item.description = bug.description
    item.reported_by = bug.reported_by
    item.component = bug.component_1_name
    if bug.component_2.length > 0
      item.component += ':' + bug.component_2
    end
    item.severity_name = bug.current_severity_name
    item.last_changed_by = bug.last_changed_by
    item
  end
end

def get_order(order_param)
  columns_available = {
      'bug_id.desc' => :bug_id.desc,
      'state.desc' => :current_state_name.desc,
      'last_changed.desc' => :last_changed.desc,
      'description.desc' => :description.desc,
      'reported_by.desc' => :reported_by.desc,
      'component.desc' => [:component_1_name.desc, :component_2.desc],
      'severity.desc' => :current_severity_name.desc,
      'last_changed_by.desc' => :last_changed_by.desc,
      'bug_id.asc' => :bug_id.asc,
      'state.asc' => :current_state_name.asc,
      'last_changed.asc' => :last_changed.asc,
      'description.asc' => :description.asc,
      'reported_by.asc' => :reported_by.asc,
      'component.asc' => [:component_1_name.asc, :component_2.asc],
      'severity.asc' => :current_severity_name.asc,
      'last_changed_by.asc' => :last_changed_by.asc
  }
  order = []
  if order_param
    order.push(columns_available[order_param]) if columns_available.has_key?(order_param)
    order = order.flatten()
  end
  order = [:last_changed.desc] if order.count == 0

  order
end

def get_states(state_param)
  #noinspection RubyStringKeysInHashInspection
  states_available = {
                       'open' => [ 1, 2 ],
                       'new' => 1,
                       'confirmed' => 2,
                       'closed' => [ 3, 4 ],
                       'verified' => 4,
                       'unverified' => 3,
                       'unbugs' => [ 5, 6 ],
                       'held' => 5,
                       'notabug' => 6
  }
  states = []
  url_option = nil
  if state_param
    if state_param == 'all'
      return [], 'all'
    end
    if states_available.has_key?(state_param)
        states.push(states_available[state_param])
        states = states.flatten()
        url_option = state_param
    end
  end
  states = [ 1, 2 ] if states.count == 0

  return states, url_option
end


get '/' do
  @current_user = authenticate!

  @title = "#{Config::APP[:name]} - Bugs"

  page = get_page(params[:page])
  page_size = get_page_size(params[:page_size])

  order = get_order(params[:order])
  states, @state_url_option = get_states(params[:state])

  @bugs = BugList.all(
      :limit => page_size,
      :offset => page*page_size,
      :order => order
  )

  unless @current_user.able_to_see_others_bugs?
    @bugs = @bugs.all( :reported_by => @current_user.username)
  end

  if states.count > 0
    @bugs = @bugs.all( :current_state_id => states )
  end

  # map model to view model bugs
  @bugs = map_bug_list_to_view_model(@bugs)

  # TODO: check for html encoding
  haml :index
end
