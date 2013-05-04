require 'rubygems'
require 'dm-core'
require 'dm-migrations'

# If you want the logs displayed you have to do this before the call to setup
#DataMapper::Logger.new($stdout, :debug)

# Why on earth would you not want to do this?!
DataMapper::Model.raise_on_save_failure = true

# A MySQL connection:
if ((defined? settings) && settings.environment == :test) || ENV['RACK_ENV'] == 'test'
  puts "Using TEST environment with connection: #{Config::TEST[:connection]}"
  DataMapper.setup(:default, Config::TEST[:connection])
  adapter = DataMapper.repository(:default).adapter
  adapter.execute('DROP VIEW IF EXISTS `bug_list_view`;')
else
  DataMapper.setup(:default, Config::DB[:connection])
end


class Bug
  include DataMapper::Resource

  storage_names[:default] = 'bug'

  property :id, Serial, :required => true
  property :user, String, :length => 255, :required => true
  property :text, Text, :required => true
  property :current_state_id, Integer, :required => true, :field => 'currentstate'
  property :current_severity_id, Integer, :required => true, :field => 'currentseverity'
  property :initial_severity_id, Integer, :required => true, :field => 'initialseverity'
  property :current_component_1_id, Integer, :required => true, :field => 'currentcomponent1'
  property :current_component_2, String, :required => true, :field => 'currentcomponent2'
  property :last_modified, DateTime, :required => true, :field => 'lastmodified'
  property :submitted, DateTime, :required => true, :field => 'submitteddate'
  property :comment_count, Integer, :required => true, :field => 'commentcount'

  has n, :comments

  # DataMapper adds _id on the end to find the property name
  belongs_to :current_state, 'State'
  belongs_to :current_severity, 'Severity'
  belongs_to :initial_severity, 'Severity'
  belongs_to :current_component_1, 'Component1'
end

class Comment
  include DataMapper::Resource

  storage_names[:default] = 'comment'

  property :bug_id, Integer, :required => true, :key => true, :field => 'bugid'
  property :comment_number, Integer, :required => true, :key => true, :field => 'id'
  property :user, String, :length => 255, :required => true
  property :text, Text
  property :new_state_id, Integer, :field => 'newstate'
  property :old_severity_id, Integer, :required => true, :field => 'oldseverity'
  property :new_severity_id, Integer, :field => 'newseverity'
  property :old_component_1_id, Integer, :required => true, :field => 'oldcomponent1'
  property :new_component_1_id, Integer, :field => 'newcomponent1'
  property :old_component_2, String, :length=>255, :required => true, :field => 'oldcomponent2'
  property :new_component_2, String, :length=>255, :field => 'newcomponent2'
  property :submitted, DateTime, :required => true
  property :is_bug_edit?, Boolean, :required => true, :field => 'isbugedit'

  belongs_to :bug, 'Bug'
  belongs_to :new_state, 'State'
  belongs_to :old_severity, 'Severity'
  belongs_to :new_severity, 'Severity'
  belongs_to :old_component_1, 'Component1'
  belongs_to :new_component_1, 'Component1'
end

class State
  include DataMapper::Resource

  storage_names[:default] = 'state'

  property :id, Serial, :required => true
  property :name, String, :length => 255, :required => true
  property :state_order, Integer, :required => true, :field => 'stateorder'
end

class Severity
  include DataMapper::Resource

  storage_names[:default] = 'severity'

  property :id, Serial, :required => true
  property :name, String, :length => 255, :required => true
  property :colour, String, :length => 255, :required => true
  property :severity_order, Integer, :required => true, :field => 'sevorder'
end

class Component1
  include DataMapper::Resource

  storage_names[:default] = 'component1'

  property :id, Serial, :required => true
  property :name, String, :length => 255, :required => true
  property :is_default, Integer, :required => false, :field => 'isdefault'
end

class BugList
  include DataMapper::Resource

  storage_names[:default] = 'bug_list_view'

  property :bug_id, Integer, :key => true
  property :comment_count, Integer
  property :current_state_id, Integer
  property :current_state_name, String, :length => 255
  property :current_severity_colour, String, :length => 255
  property :last_changed, DateTime
  property :description, Text
  property :reported_by, String, :length => 255
  property :component_1_id, Integer
  property :component_1_name, String, :length => 255
  property :component_2, String, :length => 255
  property :current_severity_id, Integer
  property :current_severity_name, String, :length => 255
  property :last_changed_by, String, :length => 255
end

if ((defined? settings) && settings.environment == :test) || ENV['RACK_ENV'] == 'test'
  DataMapper.finalize.auto_migrate!
  buglist_create_view_sql = <<EOF
DROP TABLE `bug_list_view`;
CREATE VIEW `bug_list_view` AS
  SELECT `bug`.`id` AS `bug_id`,
         `bug`.`commentcount` AS `comment_count`,
         `current_state`.`id` AS `current_state_id`,
         `current_state`.`name` AS `current_state_name`,
         `current_severity`.`colour` AS `current_severity_colour`,
         `bug`.`lastmodified` AS `last_changed`,
         `bug`.`text` AS `description`,
         `bug`.`user` AS `reported_by`,
         `component1`.`id` AS `component_1_id`,
         `component1`.`name` AS `component_1_name`,
         `bug`.`currentcomponent2` AS `component_2`,
         `current_severity`.`id` AS `current_severity_id`,
         `current_severity`.`name` AS `current_severity_name`,
         (SELECT `comment`.`user` FROM `comment`
           WHERE (`comment`.`bugid` = `bug`.`id`)
           ORDER BY `comment`.`submitted` DESC
           LIMIT 1) AS `last_changed_by`
    FROM `bug`
         JOIN `state` `current_state`
            ON (`current_state`.`id` = `bug`.`currentstate`)
         JOIN `severity` `current_severity`
            ON (`current_severity`.`id` = `bug`.`currentseverity`)
         JOIN `component1`
            ON (`component1`.`id` = `bug`.`currentcomponent1`);
EOF
  adapter = DataMapper.repository(:default).adapter
  adapter.execute(buglist_create_view_sql)
else
  DataMapper.finalize
end
