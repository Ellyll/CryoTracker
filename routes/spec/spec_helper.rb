def create_test_data
  create_test_states
  create_test_severities
  create_test_component_1s
  create_test_bugs
end

def create_test_states
  states = [
            { :name => 'new',      :state_order => 1 },
            { :name => 'open',     :state_order => 2 },
            { :name => 'fixed',    :state_order => 3 },
            { :name => 'verified', :state_order => 4 },
            { :name => 'held',     :state_order => 5 },
            { :name => 'notabug',  :state_order => 6 }
           ]

  states.each { |item| State.create(item) }
end

def create_test_severities
  severities = [
                { :id => 0,  :name => 'typo',   :colour => '#FFF68F', :severity_order => 20 },
                { :id => 1,  :name => 'minor',  :colour => '#FFFF00', :severity_order => 30 },
                { :id => 2,  :name => 'major',  :colour => '#FFA500', :severity_order => 40 },
                { :id => 3,  :name => 'severe', :colour => '#FF0000', :severity_order => 50 },
                { :id => 4,  :name => 'fatal',  :colour => '#FF00FF', :severity_order => 60 },
                { :id => 11, :name => 'wish',   :colour => '#FFFFFF', :severity_order => 10 }
               ]
  severities.each { |item| Severity.create(item) }
end

def create_test_component_1s
  component1s = [
                  { :id => 1,  :name => 'action' },
                  { :id => 2,  :name => 'buglog' },
                  { :id => 3,  :name => 'code' },
                  { :id => 4,  :name => 'general' },
                  { :id => 5,  :name => 'help' },
                  { :id => 6,  :name => 'info' },
                  { :id => 7,  :name => 'policy' },
                  { :id => 8,  :name => 'quest' },
                  { :id => 9,  :name => 'web' },
                  { :id => 10, :name => 'world' },
                  { :id => 11, :name => 'verb' },
                  { :id => 12, :name => 'unknown', :is_default => 1 }
                 ]
  component1s.each { |item| Component1.create(item) }
end

def create_test_bugs
  bugs = [
          { :user => 'testuser',
            :text => 'A. test description',
            :current_state_id => 1,
            :current_severity_id => 2,
            :initial_severity_id => 2,
            :current_component_1_id => 5,
            :current_component_2 => '',
            :last_modified => DateTime.now,
            :submitted => DateTime.now,
            :comment_count => 0
          }
         ]
  bugs.each { |item| Bug.create(item) }
end
