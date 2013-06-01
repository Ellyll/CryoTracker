require 'rack/test'
require 'rspec'
#require 'sinatra'

# Set the Sinatra environment
#set :environment, :test
ENV['RACK_ENV'] = 'test'

require_relative '../app'
require_relative 'test_data_helper'

def app
  Sinatra::Application
end