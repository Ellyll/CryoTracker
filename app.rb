require 'rubygems'
require 'sinatra'
require 'haml'

require_relative 'config'
require_relative 'models/bugs'
require_relative 'view_models/bug_list_item_view_model'
require_relative 'helpers/main'

require_relative 'routes/index'
require_relative 'routes/bug'
