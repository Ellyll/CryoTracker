
describe 'The fixed bugs service' do
  it 'should provide a list bugs that have been fixed within the specified amount of time' do
    service = FixedBugsService.new(Bug)
    days = 7
    bugs = service.get_recently_fixed_bugs(days)

    bugs.count.should == 2
    bugs.each do |bug|
      bug.last_modified.should >= DateTime.new - days
      bug.current_state_id.should == 3 # fixed
    end
  end

  it 'should provide a list of bugs that require verification' do
    service = FixedBugsService.new(Bug)
    bugs = service.get_bugs_requiring_verification()

    bugs.count.should == 3
    bugs.each do |bug|
      bug.current_state_id.should == 3 # fixed
    end
  end
end