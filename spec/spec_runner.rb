ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'app'
require 'rspec'
require 'rack/test'
require 'nokogiri'
require 'services/fixed_bugs_service'

require 'spec/spec_helper'

#set :environment, :test
create_test_data

def app
  Sinatra::Application
end

# Specs:
require 'spec/routes/index_spec'
require 'spec/services/fixed_bugs_service_spec'