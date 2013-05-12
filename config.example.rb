module Config
  APP = { :name => 'CryoTracker', :default_page_size => 20 }
  DB = { :connection => 'mysql://user:password@localhost/databasename' }
  AUTHENTICATION = { :user_files_directory => '/some/path/vardata/users' }
  TEST = {
          :user_files_directory => File.dirname(__FILE__) + '/spec/services/testusers',
          :test_user_username => 'testbot',
          :test_user_password => 'mmmhufenia',
          :connection => "sqlite3://#{Dir.pwd}/cryotracker_test.db"
         }
end

