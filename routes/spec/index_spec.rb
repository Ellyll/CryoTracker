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

  def check_bug_list_order(order, css_selector, is_ascending, content_modifier)
    doc = get_page_with_order(order)
    bugs = doc.css(css_selector).map {|b| b.content}
    bugs.count.should > 0

    if content_modifier
      bugs = bugs.map { |b| content_modifier.call(b) }
    end

    max_value = bugs.max_by {|b| b}
    min_value = bugs.min_by {|b| b}

    last_value = is_ascending ? min_value : max_value
    bugs.each do |bug|
      if is_ascending
        bug.should >= last_value
      else
        bug.should <= last_value
      end
      last_value = bug
    end
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
    modifier = lambda { |b| b.delete('*').to_i }
    check_bug_list_order('bug_id.asc', 'td.bug_id', true, modifier)
  end

  it 'should allow bugs to be sorted by id descending' do
    modifier = lambda { |b| b.delete('*').to_i }
    check_bug_list_order('bug_id.desc', 'td.bug_id', false, modifier)
  end

  it 'should allow bugs to be sorted by state_name ascending' do
    check_bug_list_order('state.asc', 'td.state_name', true, nil)
  end

  it 'should allow bugs to be sorted by state_name descending' do
    check_bug_list_order('state.desc', 'td.state_name', false, nil)
  end

  it 'should allow bugs to be sorted by last_changed ascending' do
    check_bug_list_order('last_changed.asc', 'td.last_changed', true, nil)
  end

  it 'should allow bugs to be sorted by last_changed descending' do
    check_bug_list_order('last_changed.desc', 'td.last_changed', false, nil)
  end

  it 'should allow bugs to be sorted by description ascending' do
    modifier = lambda { |b| b.upcase }
    check_bug_list_order('description.asc', 'td.description', true, modifier)
  end

  it 'should allow bugs to be sorted by description descending' do
    modifier = lambda { |b| b.upcase }
    check_bug_list_order('description.desc', 'td.description', false, modifier)
  end

  it 'should allow bugs to be sorted by reported_by ascending' do
    check_bug_list_order('reported_by.asc', 'td.reported_by', true, nil)
  end

  it 'should allow bugs to be sorted by reported_by descending' do
    check_bug_list_order('reported_by.desc', 'td.reported_by', false, nil)
  end

  it 'should allow bugs to be sorted by component ascending' do
    check_bug_list_order('component.asc', 'td.component', true, nil)
  end

  it 'should allow bugs to be sorted by component descending' do
    check_bug_list_order('component.desc', 'td.component', false, nil)
  end

  it 'should allow bugs to be sorted by severity_name ascending' do
    check_bug_list_order('severity.asc', 'td.severity_name', true, nil)
  end

  it 'should allow bugs to be sorted by severity descending' do
    check_bug_list_order('severity.desc', 'td.severity_name', false, nil)
  end

  it 'should allow bugs to be sorted by last_changed_by ascending' do
    check_bug_list_order('last_changed_by.asc', 'td.last_changed_by', true, nil)
  end

  it 'should allow bugs to be sorted by last_changed_by descending' do
    check_bug_list_order('last_changed_by.desc', 'td.last_changed_by', false, nil)
  end

end