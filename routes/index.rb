


# @return BugListViewModelItem[]
def map_bug_list_to_view_model(bugs)
  mapped_bugs = bugs.map do |bug|
    item = BugListItemViewModel.new
    item.bug_id = bug.bug_id
    item.comment_count = bug.comment_count
    item.current_state_name = bug.current_state_name
    item.current_severity_colour = bug.current_severity_colour
    item.last_changed = bug.last_changed
    item.description = bug.description
    item.reported_by = bug.reported_by
    item.component = bug.component_1_name
    if bug.component_2.length > 0
      item.component += ':' + bug.component_2
    end
    item.severity_name = bug.current_severity_name
    item.last_change_by = bug.last_changed_by
    item
  end

  mapped_bugs
end

def get_order(order_param)
  columns_available = {
      'bug_id.desc' => :bug_id.desc,
      'state.desc' => :current_state_name.desc,
      'last_changed.desc' => :last_changed.desc,
      'reported_by.desc' => :reported_by.desc,
      'component.desc' => [:component_1_name.desc, :component_2.desc],
      'severity.desc' => :current_severity_name.desc,
      'last_changed_by.desc' => :last_changed_by.desc
  }
  order = []
  if order_param
    order_param.each do |column|
      order.push(columns_available[column]) if columns_available.has_key?(column)
    end
    order = order.flatten()
  end
  order = [:last_changed.desc] if order.count == 0

  order
end

def get_states(state_param)
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
  if state_param
    if state_param == 'all'
      return []
    end
    state_param.each do |state|
      states.push(states_available[state]) if states_available.has_key?(state)
    end
    states = states.flatten()
  end
  states = [ 1, 2 ] if states.count == 0

  states
end


get '/' do
  protected!
  @title = "#{Config::APP[:name]} - Bugs"
  #TODO: check if user is banned

  page = get_page(params[:page])
  page_size = get_page_size(params[:page_size])

  order = get_order(params[:order])
  states = get_states(params[:state])

  @bugs = BugList.all(
      :limit => page_size,
      :offset => page*page_size,
      :order => order
  )

  if states.count > 0
    puts "DEBUG: states: #{states.join('|')}"
    @bugs = @bugs.all( :current_state_id => states )
  end

  # map model to view model bugs
  @bugs = map_bug_list_to_view_model(@bugs)

  # TODO: check for html encoding
  haml :index
end
