#require_relative '../../app.rb'
require File.dirname(__FILE__) + '/../../app.rb'
require 'rspec'
require 'rack/test'
require 'nokogiri'

set :environment, :test

def app
  Sinatra::Application
end

describe 'The index route' do
  include Rack::Test::Methods

  def do_auth
    #TODO: move to config
    authorize(Config::TEST[:test_user_username], Config::TEST[:test_user_password])
  end

  def get_page_with_order(order)
    do_auth
    get "/?order=#{order}"

    Nokogiri::HTML(last_response.body)
  end


  it 'should not allow unathorised access' do
    get '/'
    last_response.status.should == 401 # Unauthorised
  end

  it 'should load the home page' do
    do_auth
    get '/'

    last_response.should be_ok
  end

  it 'should allow bugs to be sorted by id ascending' do
    doc = get_page_with_order('bug_id.asc')
    bugs = doc.css('td.bug_id')
    bugs.count.should > 0

    last_bug_id = -1
    bugs.each do |bug|
      bug_id = bug.content.delete('*').to_i
      bug_id.should > last_bug_id
      last_bug_id = bug_id
    end
  end

  it 'should allow bugs to be sorted by id descending' do
    doc = get_page_with_order('bug_id.desc')
    bugs = doc.css('td.bug_id')
    bugs.count.should > 0

    last_bug_id = 999_999_999 # needs to be higher than the biggest bug_id
    bugs.each do |bug|
      bug_id = bug.content.delete('*').to_i
      bug_id.should < last_bug_id
      last_bug_id = bug_id
    end
  end

  it 'should allow bugs to be sorted by state_name ascending' do
    doc = get_page_with_order('state.asc')
    bugs = doc.css('td.state_name')
    bugs.count.should > 0

    last_state = ''
    bugs.each do |bug|
      bug.content.should >= last_state
      last_state = bug.content
    end
  end

  it 'should allow bugs to be sorted by state_name descending' do
    doc = get_page_with_order('state.desc')
    bugs = doc.css('td.state_name')
    bugs.count.should > 0

    last_state = '~' # Assumes state name is ASCII a-Z
    bugs.each do |bug|
      bug.content.should <= last_state
      last_state = bug.content
    end
  end

  it 'should allow bugs to be sorted by last_changed ascending' do
    doc = get_page_with_order('last_changed.asc')
    bugs = doc.css('td.last_changed')
    bugs.count.should > 0

    last_last_changed = '0000-00-00 00:00:00'
    bugs.each do |bug|
      bug.content.should >= last_last_changed
      last_last_changed = bug.content
    end
  end

  it 'should allow bugs to be sorted by last_changed descending' do
    doc = get_page_with_order('last_changed.desc')
    bugs = doc.css('td.last_changed')
    bugs.count.should > 0

    last_last_changed = DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    bugs.each do |bug|
      bug.content.should <= last_last_changed
      last_last_changed = bug.content
    end
  end

  it 'should allow bugs to be sorted by description ascending' do
    doc = get_page_with_order('description.asc')
    bugs = doc.css('td.description')
    bugs.count.should > 0

    last_description = ''
    bugs.each do |bug|
      bug_desc = bug.content.upcase
      bug_desc.should >= last_description
      last_description = bug_desc
    end
  end

  it 'should allow bugs to be sorted by description descending' do
    doc = get_page_with_order('description.desc')
    bugs = doc.css('td.description')
    bugs.count.should > 0

    last_description = '~' # Assumes description starts with char less than ~
    bugs.each do |bug|
      bug_desc = bug.content.upcase
      bug_desc.should <= last_description
      last_description = bug_desc
    end
  end

  it 'should allow bugs to be sorted by reported_by ascending' do
    doc = get_page_with_order('reported_by.asc')
    bugs = doc.css('td.reported_by')
    bugs.count.should > 0

    last_reported_by = ''
    bugs.each do |bug|
      bug.content.should >= last_reported_by
      last_reported_by = bug.content
    end
  end

  it 'should allow bugs to be sorted by reported_by descending' do
    doc = get_page_with_order('reported_by.desc')
    bugs = doc.css('td.reported_by')
    bugs.count.should > 0

    last_reported_by = '~'
    bugs.each do |bug|
      bug.content.should <= last_reported_by
      last_reported_by = bug.content
    end
  end

  it 'should allow bugs to be sorted by component ascending' do
    doc = get_page_with_order('component.asc')
    bugs = doc.css('td.component')
    bugs.count.should > 0

    last_component = ''
    bugs.each do |bug|
      bug.content.should >= last_component
      last_component = bug.content
    end
  end

  it 'should allow bugs to be sorted by component descending' do
    doc = get_page_with_order('component.desc')
    bugs = doc.css('td.component')
    bugs.count.should > 0

    last_component = '~'
    bugs.each do |bug|
      bug.content.should <= last_component
      last_component = bug.content
    end
  end

  it 'should allow bugs to be sorted by severity_name ascending' do
    doc = get_page_with_order('severity.asc')
    bugs = doc.css('td.severity_name')
    bugs.count.should > 0

    last_severity = ''
    bugs.each do |bug|
      bug.content.should >= last_severity
      last_severity = bug.content
    end
  end

  it 'should allow bugs to be sorted by severity descending' do
    doc = get_page_with_order('severity.desc')
    bugs = doc.css('td.severity_name')
    bugs.count.should > 0

    last_severity = '~'
    bugs.each do |bug|
      bug.content.should <= last_severity
      last_severity = bug.content
    end
  end

  it 'should allow bugs to be sorted by last_changed_by ascending' do
    doc = get_page_with_order('last_changed_by.asc')
    bugs = doc.css('td.last_changed_by')
    bugs.count.should > 0

    last_last_changed_by = ''
    bugs.each do |bug|
      bug.content.should >= last_last_changed_by
      last_last_changed_by = bug.content
    end
  end

  it 'should allow bugs to be sorted by last_changed_by descending' do
    doc = get_page_with_order('last_changed_by.desc')
    bugs = doc.css('td.last_changed_by')
    bugs.count.should > 0

    last_last_changed_by = '~'
    bugs.each do |bug|
      bug.content.should <= last_last_changed_by
      last_last_changed_by = bug.content
    end
  end

end