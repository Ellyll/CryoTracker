require_relative '../spec_helper'
require 'nokogiri'

create_test_data

describe 'GET /index' do
  include Rack::Test::Methods

  def do_auth
    authorize(Config::TEST[:test_user_username], Config::TEST[:test_user_password])
  end

  def check_bugs_table_is_sorted(body, css_selector, is_ascending, content_modifier)
    doc = Nokogiri::HTML(body)
    bugs = doc.css(css_selector).map {|b| b.content}
    bugs.count.should > 0

    is_sorted = true

    if content_modifier
      bugs = bugs.map { |b| content_modifier.call(b) }
    end

    max_value = bugs.max_by {|b| b}
    min_value = bugs.min_by {|b| b}

    last_value = is_ascending ? min_value : max_value
    bugs.each do |bug|
      if is_ascending
        expect(bug).to be >= last_value
        is_sorted = false unless bug >= last_value
      else
        expect(bug).to be <= last_value
        is_sorted = false unless bug <= last_value
      end
      last_value = bug
    end

    is_sorted
  end

  def get_state_names_from_body(body)
    doc = Nokogiri::HTML(body)
    #puts "body: #{body}"
    doc.css('td.state_name').map {|b| b.content}
  end

  def get_reported_by_from_body(body)
    doc = Nokogiri::HTML(body)
    doc.css('td.reported_by').map {|b| b.content}
  end

  context 'when not given login credentials' do
    it 'responds with status 401 (Unauthorised)' do
      get '/'
      expect(last_response.status).to eq(401) # Unauthorised
    end
  end

  context 'when given invalid login credentials' do
    it 'responds with status 401 (Unauthorised)' do
      authorize('not_a_real_user', 'not_a_valid_password')
      get '/'
      expect(last_response.status).to eq(401) # Unauthorised
    end
  end

  context 'when given valid login credentials' do

    context 'and user is banned' do
      before do
        authorize('testbotbugbanned', 'mmmhufenia')
        get '/'
      end
      subject { last_response }
      its(:status) { should eq(403) } # Forbidden
    end

    context 'and user.able_to_see_others_bugs? is false' do
      it 'shows only the user\'s own bugs' do
        username = 'abletoseeallbugsfalse'
        authorize(username, 'mmmhufenia')
        get '/'
        users = get_reported_by_from_body(last_response.body)
        others = users.select { |u| u != username }
        mine = users.select { |u| u == username }

        expect(others).to be_empty
        expect(mine).to_not be_empty
      end
    end

    context 'and user.able_to_see_others_bugs? is true' do
      it 'shows other users\' bugs' do
        username = 'abletoseeallbugstrue'
        authorize(username, 'mmmhufenia')
        get '/'
        users = get_reported_by_from_body(last_response.body)
        others = users.select { |u| u != username }
        mine = users.select { |u| u == username }

        expect(others).to_not be_empty
        expect(mine).to_not be_empty
      end
    end

    context 'without any parameters, the response' do
      before { do_auth; get '/' }
      subject { last_response }
      it { should be_ok }
      its(:status) { should eq(200) }
    end

    context 'without a sort parameter' do
      it 'will be sorted by last_changed' do
        do_auth
        get '/'
        check_bugs_table_is_sorted(last_response.body, 'td.last_changed', false, nil)
      end
    end

    context 'with a sort parameter' do
      sort_param = {
                    :bug_id       => { :css_class => 'td.bug_id', :modifier =>  lambda { |b| b.delete('*').to_i } },
                    :state        => { :css_class => 'td.state_name' },
                    :last_changed => { :css_class => 'td.last_changed' },
                    :description  => { :css_class => 'td.description', :modifier => lambda { |b| b.upcase } },
                    :reported_by  => { :css_class => 'td.reported_by' },
                    :component    => { :css_class => 'td.component' },
                    :severity     => { :css_class => 'td.severity_name' },
                    :last_changed_by => { :css_class => 'td.last_changed_by' }
                   }

      direction = { :asc => true, :desc => false }
      sort_param.each do |column,param|
        context "#{column}" do
          direction.each do |dir,ascending|
            context "#{dir.to_s}" do
              subject(:response) do
                do_auth
                get "/?order=#{column}.#{dir.to_s}"
                last_response
              end
              it { should be_ok }
              its(:status) { should eq(200) }
              it 'be sorted' do
                check_bugs_table_is_sorted(response.body, param[:css_class], ascending, param[:modifier])
              end
            end
          end
        end
      end
    end

    context 'without a state parameter' do
      it 'shows only bugs with a states of "open" or "new"' do
        do_auth
        get '/'
        state_names = Set.new(get_state_names_from_body(last_response.body))
        expect(state_names).to_not be_empty # must have some test data with allowed state names
        allowed_state_names = Set.new(%w(new open))
        invalid_state_names = state_names - allowed_state_names
        expect(invalid_state_names).to be_empty
      end
    end

    context 'with a state parameter' do
      states = {
                :open => %w(new open),
                :new => %w(new),
                :confirmed => %w(open),
                :closed => %w(fixed verified),
                :verified => %w(verified),
                :unverified => %w(fixed),
                :unbugs => %w(held notabug),
                :held => %w(held),
                :notabug => %w(notabug)
              }
      states.each do |name, allowed_state_names|
        context "#{name}" do
          subject(:response) do
            do_auth
            get "/?state=#{name.to_s}"
            last_response
          end
          it { should be_ok }
          its(:status) { should eq(200) }
          it "only shows bugs with states of #{allowed_state_names.to_s}" do
            state_names = get_state_names_from_body(response.body)
            expect(state_names).to_not be_empty # must have some test data with allowed state names
            invalid_state_names = state_names.select { |state| !allowed_state_names.include?(state) }
            expect(invalid_state_names).to be_empty
          end
        end
      end
      context 'all' do
        subject(:response) do
          do_auth
          get '/?state=all'
          last_response
        end
        it { should be_ok }
        its(:status) { should eq(200) }
        it 'shows all states' do
          state_names = get_state_names_from_body(response.body)
          states_set = Set.new(state_names)
          expect(states_set).to_not be_empty
          expect(states_set.count).to be > 1 # should be more than one state
        end
      end
    end
  end
end