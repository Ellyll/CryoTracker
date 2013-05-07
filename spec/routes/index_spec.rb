require 'rack/test'
require 'rspec'


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
    before(:each) { do_auth }

    context 'without any parameters, the response' do
      before { get '/' }
      subject { last_response }
      it { should be_ok }
      its(:status) { should eq(200) }
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
  end
end