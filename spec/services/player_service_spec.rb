require 'rspec'
require_relative '../../services/player_service'

describe PlayerService do
  describe '#initialize' do
    context 'when not given a directory path' do
      it 'raises an ArgumentError' do
        #noinspection RubyArgCount
        expect { PlayerService.new }.to raise_error(ArgumentError)
        expect { PlayerService.new(nil) }.to raise_error(ArgumentError)
      end
    end
    context 'when given a directory path that is not a directory' do
      it 'raises an ArgumentError' do
        filename = File.dirname(__FILE__) + '/non_existant_directory'
        expect { PlayerService.new(filename) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#get_flags' do
    player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')

    context 'when not given a username' do
      it 'raises an ArgumentError' do
        #noinspection RubyArgCount
        expect { player_service.get_flags() }.to raise_error(ArgumentError)
      end
    end
    context 'when given a nil username' do
      it 'raises an ArgumentError' do
        expect { player_service.get_flags(nil) }.to raise_error(ArgumentError)
      end
    end
    context 'when given a username with an invalid format' do
      it 'raises an ArgumentError' do
        expect { player_service.get_flags('/../../l!ttl3B[]88!3T/-\bL3z>""<<>') }.to raise_error(ArgumentError)
      end
    end
    context 'when given a non-existant username' do
      it 'raises a SystemCallError' do
        expect { player_service.get_flags('non_existant_user') }.to raise_error(ArgumentError)
      end
    end
    context 'when given a valid username' do
      it "return the player's flags as a set" do
        flags = player_service.get_flags('testbot')
        expected_flags = Set.new(%w(LoggedIn Colour NewNews))

        expect(flags.class).to eq(Set) # Expect returned flags to be a Set
        expect(flags).to eq(expected_flags)
      end
    end
  end

  describe '#get_email' do
    player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
    context 'when given a non-existant username' do
      it 'raises a SystemCallError' do
        expect { player_service.get_email('non_existant_user') }.to raise_error(ArgumentError)
      end
    end
    context 'when given a valid username' do
      it "returns the player's email address when it's defined" do
        email = player_service.get_email('testbot')
        expect(email).to eq('testbot@cryosphere.net')
      end
      it "returns nil when the player's email address is not defined" do
        email = player_service.get_email('testbot2')
        expect(email).to be_nil
      end
    end
  end

  describe '#see_bugs?' do
    player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
    context 'when given a valid username' do
      context 'when player has level >= 23 and does not have the SeeBugs pflag denied' do
        it 'returns true' do
          expect( player_service.see_bugs?('testbotseebugs1') ).to be_true
        end
      end
      context 'when player has level >= 23 and has the SeeBugs pflag denied' do
        it 'returns false' do
          expect( player_service.see_bugs?('testbotseebugs2') ).to_not be_nil
          expect( player_service.see_bugs?('testbotseebugs2') ).to be_false
        end
      end
      context 'when player has level < 23 and does not have the SeeBugs pflag granted' do
        it 'returns false' do
          expect( player_service.see_bugs?('testbotseebugs3') ).to_not be_nil
          expect( player_service.see_bugs?('testbotseebugs3') ).to be_false
        end
      end
      context 'when player has level < 23 and has the SeeBugs pflag granted' do
        it 'returns true' do
          expect( player_service.see_bugs?('testbotseebugs4') ).to be_true
        end
      end
    end
  end

  # private methods specs

  describe '#get_filename' do
    it 'returns the filename for the given username' do
      player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
      filename = player_service.send(:get_filename, 'testbot') # workaround for private method
      expected_filename = File.dirname(__FILE__) + '/testusers/testbot'
      expect(filename).to eq(expected_filename)
    end
  end

  describe '#get_int_value' do
    it 'returns the value for an int attribute' do
      player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
      int_value = player_service.send(:get_int_value, 'privs', 'testbot')
      expect(int_value).to eq(9997)
    end
  end

  describe '#get_granted_flags' do
    it 'returns any "granted" pflags' do
      player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
      granted = player_service.send(:get_granted_flags, 'testbotseebugs4')
      expected = Set.new %w(Tester SeeBugs)
      expect(granted).to eq(expected)
    end
  end

  describe '#get_withheld_flags' do
    it 'returns any "withheld" pflags' do
      player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
      withheld = player_service.send(:get_withheld_flags, 'testbotseebugs2')
      expected = Set.new %w(SeeBugs)
      expect(withheld).to eq(expected)
    end
  end

  describe '#get_permission_level' do
    it 'returns the int value of the effective permission when player has privs set' do
      player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
      level = player_service.send(:get_permission_level, 'testbot')
      expect(level).to eq(9997)
    end
    it "returns the int value of the effective permission when player doesn't have privs set" do
      player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
      level = player_service.send(:get_permission_level, 'testbotseebugs4')
      expect(level).to eq(20)
    end

  end

end