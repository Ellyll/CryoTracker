require_relative '../spec_helper'
require 'nokogiri'

create_test_data

describe 'GET /bug' do
  include Rack::Test::Methods


  def do_auth
    authorize(Config::TEST[:test_user_username], Config::TEST[:test_user_password])
  end

  valid_bug_id = 1

  context 'when not given login credentials' do
    it 'responds with status 401 (Unauthorised)' do
      get "/bug/#{valid_bug_id}"
      expect(last_response.status).to eq(401) # Unauthorised
    end
  end

  context 'when given invalid login credentials' do
    it 'responds with status 401 (Unauthorised)' do
      authorize('not_a_real_user', 'not_a_valid_password')
      get "/bug/#{valid_bug_id}"
      expect(last_response.status).to eq(401) # Unauthorised
    end
  end

  context 'when given valid login credentials' do

    context 'and user is banned' do
      before do
        authorize('testbotbugbanned', 'mmmhufenia')
        get "/bug/#{valid_bug_id}"
      end
      subject { last_response }
      its(:status) { should eq(403) } # Forbidden
    end

    context 'when given an invalid bug_id' do
      context 'as not given a bug_id' do
          it 'responds with status 400 (Bad Request)' do
            do_auth
            get '/bug/'
            subject { last_response }
            expect(last_response.status).to eq(400)
          end
      end


      context 'as given a non-numerical bug_id' do
        it 'responds with status 400 (Bad Request)' do
          do_auth
          get '/bug/abc'
          subject { last_response }
          expect(last_response.status).to eq(400)
        end
      end

      context 'as given a non-existant bug id' do
        it 'responds with status 404 (Not Found)' do
          do_auth

          invalid_bug_id = 99999
          get "/bug/#{invalid_bug_id}"
          expect(last_response.status).to eq(404)
        end
      end

      context 'as given a bug id of bug that was submitted by a different user to current user' do
        context 'and current user cannot see bugs belonging to others' do
          it 'responds with a status of 403' do
            username = 'abletoseeallbugsfalse'
            authorize(username, 'mmmhufenia')
            get "/bug/#{valid_bug_id}"
            expect(last_response.status).to eq(403)
          end
        end
      end
    end

    context 'when given a valid bug_id' do
      subject(:doc) do
        authorize('testbot', 'mmmhufenia')
        get '/bug/1'
        doc = Nokogiri::HTML(last_response.body)
      end

      it 'sets the title' do
        title = doc.css('title').map {|t| t.content}
        expect(title.count).to eq(1) # should be exactly 1 title tag
        expect(title[0]).to eq('CryoTracker - Bug 1')
      end

      it 'displays the bug id' do
        bug_id = doc.css('table.bug > tr.bug_id > td').map {|t| t.content}
        expect(bug_id.count).to eq(1) # should be exactly 1 bug ID
        expect(bug_id[0]).to eq('1')
      end

      it 'displays the reporter' do
        reported_by = doc.css('table.bug > tr.reported_by > td').map {|t| t.content}
        expect(reported_by.count).to eq(1) # should be exactly 1 reported_by
        expect(reported_by[0]).to eq('testuser')
      end

      it 'displays the state' do
        state = doc.css('table.bug > tr.state > td').map {|t| t.content}
        expect(state.count).to eq(1) # should be exactly 1 state
        expect(state[0]).to eq('new')
      end

      it 'displays the date submitted' do
        submitted = doc.css('table.bug > tr.submitted > td').map {|t| t.content}
        expect(submitted.count).to eq(1) # should be exactly 1 submitted
        expect(submitted[0]).to match /^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d$/
      end

      it 'displays the component' do
        component = doc.css('table.bug > tr.component > td').map {|t| t.content}
        expect(component.count).to eq(1) # should be exactly 1 submitted
        expect(component[0]).to eq('help')
      end

      it 'displays the severity' do
        severity = doc.css('table.bug > tr.severity > td').map {|t| t.content}
        expect(severity.count).to eq(1) # should be exactly 1 severity
        expect(severity[0]).to eq('major')
      end

      it 'displays the description' do
        description = doc.css('table.bug > tr.description > td').map {|t| t.content}
        expect(description.count).to eq(1) # should be exactly 1 severity
        expect(description[0]).to eq('A. test description')
      end
    end
  end
end
