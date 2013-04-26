module Config
  APP = { :name => 'CryoTracker', :default_page_size => 20 }
  DB = { :connection => 'mysql://user:password@localhost/databasename' }
  AUTHENTICATION = { :user_files_directory => '/some/path/vardata/users' }
  TEST = { :test_user_username => 'testuser', :test_user_password => 'testpassword' }
end

