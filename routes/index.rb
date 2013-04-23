


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


get '/' do
  protected!
  @title = "#{Config::APP[:name]} - Bugs"
  #TODO: check if user is banned

  page = get_page(params[:page])
  page_size = get_page_size(params[:page_size])

  order = get_order(params[:order])

  @bugs = BugList.all(
      :current_state_id => [1,2],
      :limit => page_size,
      :offset => page*page_size,
      :order => order
  )

  # map model to view model bugs
  @bugs = map_bug_list_to_view_model(@bugs)

  # TODO: check for html encoding
  haml :index
end
