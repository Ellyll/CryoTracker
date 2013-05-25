ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'rspec'
require 'rack/test'
require 'nokogiri'
require_relative '../app'
require_relative '../services/fixed_bugs_service'

require_relative 'spec_helper'

#set :environment, :test
create_test_data

def app
  Sinatra::Application
end

# Specs:
require_relative 'routes/index_spec'
require_relative 'services/authentication_service_spec'
require_relative 'services/fixed_bugs_service_spec'
require_relative 'services/player_data_service_spec'
require_relative 'services/player_data_deserialiser_spec'
require_relative 'services/player_data_serialiser_spec'
require_relative 'services/user_service_spec'
