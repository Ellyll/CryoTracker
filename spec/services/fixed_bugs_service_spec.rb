require_relative '../spec_helper'
require_relative '../../services/fixed_bugs_service'

create_test_data


describe FixedBugsService do
  describe '#get_recently_fixed_bugs' do
    context 'when given a number of days > 0' do
      it 'returns a list bugs that have been fixed within that time' do
        service = FixedBugsService.new(Bug)
        days = 7
        bugs = service.get_recently_fixed_bugs(days)

        bugs.count.should >= 2 # need some actual data for it to be a valid test
        bugs.each do |bug|
          bug.last_modified.should >= DateTime.new - days
          bug.current_state_id.should == 3 # fixed
        end
      end
    end
    context 'when given a number of days <= 0' do
      it 'raises an ArgumentError' do
        service = FixedBugsService.new(Bug)
        expect { service.get_recently_fixed_bugs(0) }.to raise_error(ArgumentError)
        expect { service.get_recently_fixed_bugs(-1) }.to raise_error(ArgumentError)
        expect { service.get_recently_fixed_bugs(-5) }.to raise_error(ArgumentError)
      end
    end
    context 'when not given a number or given nil' do
      it 'raises an ArgumentError' do
        service = FixedBugsService.new(Bug)
        expect { service.get_recently_fixed_bugs() }.to raise_error(ArgumentError)
        expect { service.get_recently_fixed_bugs(nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#get_bugs_requiring_verification' do
    it 'returns a list of bugs that require verification' do
      service = FixedBugsService.new(Bug)
      bugs = service.get_bugs_requiring_verification()

      bugs.count.should >= 2 # need some actual data for it to be a valid test
      bugs.each do |bug|
        bug.current_state_id.should == 3 # fixed
      end
    end
  end
end