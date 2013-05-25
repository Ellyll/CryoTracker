require 'rspec'
require_relative '../../services/user_service'
require_relative '../../services/player_data_deserialiser'
require_relative '../../services/player_data_service'

describe UserService do
  describe '#initialize' do
    context 'when not given a player data service and a player data deserialiser' do
      it 'raises an ArgumentError' do
        #noinspection RubyArgCount
        expect { UserService.new }.to raise_error(ArgumentError)
        expect { UserService.new(nil, nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#get_user' do

    player_data_deserialiser = PlayerDataDeserialiser.new
    player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
    user_service = UserService.new(player_data_service, player_data_deserialiser)

    context 'when not given a username' do
      it 'raises an ArgumentError' do
        #noinspection RubyArgCount
        expect { user_service.get_user() }.to raise_error(ArgumentError)
      end
    end

    context 'when given a nil username' do
      it 'raises an ArgumentError' do
        expect { user_service.get_user(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when given a non-existant username' do
      it 'raises a ArgumentError' do
        expect { user_service.get_user('non_existant_user') }.to raise_error(ArgumentError)
      end
    end

    context 'when given a valid username' do
      subject(:user) { user_service.get_user('testbot') }

      it 'returns a User object' do
        expect(user.class).to eq(User)
      end

      it 'sets username on the returned User' do
        expect(user.username).to eq('testbot')
      end

      it 'sets email_address on the returned User' do
        expect(user.email_address).to eq('testbot@cryosphere.net')
      end

      it 'sets banned on the returned User' do
        expect(user).to_not be_banned
      end

      it 'sets able_to_see_others_bugs on returned User' do
        expect(user).to be_able_to_see_others_bugs
      end
    end
  end

  # private

  describe '#see_bugs?' do
    player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
    player_data_deserialiser = PlayerDataDeserialiser.new
    user_service = UserService.new(player_data_service, player_data_deserialiser)

    context 'when player has level >= 23 and does not have the SeeBugs pflag denied' do
      it 'returns true' do
        player_data = player_data_service.get_player_data('testbotseebugs1')
        player = player_data_deserialiser.deserialise(player_data)

        expect( user_service.send(:see_bugs?, player) ).to be_true
      end
    end
    context 'when player has level >= 23 and has the SeeBugs pflag denied' do
      it 'returns false' do
        player_data = player_data_service.get_player_data('testbotseebugs2')
        player = player_data_deserialiser.deserialise(player_data)

        expect( user_service.send(:see_bugs?, player) ).to_not be_nil
        expect( user_service.send(:see_bugs?, player) ).to be_false
      end
    end
    context 'when player has level < 23 and does not have the SeeBugs pflag granted' do
      it 'returns false' do
        player_data = player_data_service.get_player_data('testbotseebugs3')
        player = player_data_deserialiser.deserialise(player_data)

        expect( user_service.send(:see_bugs?, player) ).to_not be_nil
        expect( user_service.send(:see_bugs?, player) ).to be_false
      end
    end
    context 'when player has level < 23 and has the SeeBugs pflag granted' do
      it 'returns true' do
        player_data = player_data_service.get_player_data('testbotseebugs4')
        player = player_data_deserialiser.deserialise(player_data)

        expect( user_service.send(:see_bugs?, player) ).to be_true
      end
    end
  end

=begin
  describe '#get_flags' do
    player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
    player_service = PlayerService.new(player_data_service)

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
    player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
    player_service = PlayerService.new(player_data_service)

    context 'when given a non-existant username' do
      it 'raises an ArgumentError' do
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
    player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
    player_service = PlayerService.new(player_data_service)

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

  describe '#banned?' do
    player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
    player_service = PlayerService.new(player_data_service)

    it 'returns true if player is banned' do
      banned = player_service.send(:banned?, 'testbotbugbanned')
      expect(banned).to be_true
    end
    it 'returns false if player is not banned' do
      banned = player_service.send(:banned?, 'testbot')
      expect(banned).to be_false
    end
  end

  describe '#get_int_value' do
    it 'returns the value for an int attribute' do
      player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
      player_service = PlayerService.new(player_data_service)

      int_value = player_service.send(:get_int_value, 'privs', 'testbot')
      expect(int_value).to eq(9997)
    end
  end

  describe '#get_granted_flags' do
    it 'returns any "granted" pflags' do
      player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
      player_service = PlayerService.new(player_data_service)

      granted = player_service.send(:get_granted_flags, 'testbotseebugs4')
      expected = Set.new %w(Tester SeeBugs)
      expect(granted).to eq(expected)
    end
  end

  describe '#get_withheld_flags' do
    it 'returns any "withheld" pflags' do
      player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
      player_service = PlayerService.new(player_data_service)

      withheld = player_service.send(:get_withheld_flags, 'testbotseebugs2')
      expected = Set.new %w(SeeBugs)
      expect(withheld).to eq(expected)
    end
  end

  describe '#get_permission_level' do
    it 'returns the int value of the effective permission when player has privs set' do
      player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
      player_service = PlayerService.new(player_data_service)

      level = player_service.send(:get_permission_level, 'testbot')
      expect(level).to eq(9997)
    end
    it "returns the int value of the effective permission when player doesn't have privs set" do
      player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
      player_service = PlayerService.new(player_data_service)

      level = player_service.send(:get_permission_level, 'testbotseebugs4')
      expect(level).to eq(20)
    end

  end
=end

end