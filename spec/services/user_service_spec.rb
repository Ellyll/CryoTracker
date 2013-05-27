require 'rspec'
require_relative '../../services/user_service'
require_relative '../../services/player_data_deserialiser'
require_relative '../../services/player_data_serialiser'
require_relative '../../services/player_data_service'

describe UserService do

  def make_user_service(player_details = {})
    deserialiser = PlayerDataDeserialiser.new
    serialiser = PlayerDataSerialiser.new

    player_data_service = double('player_data_service')
    player_data_service.stub(:get_player_data) do
      player = make_player(player_details)
      player_data = serialiser.serialise(player)
      player_data
    end

    UserService.new(player_data_service, deserialiser)
  end

  def make_player(player_details = {})
    player = Player.new

    unless player_details.nil?
      player.username = player_details[:username]
      player.flags = player_details[:flags]
      player.granted = player_details[:granted]
      player.withheld = player_details[:withheld]
      player.missions = player_details[:missions]
      player.strings = player_details[:strings]
      player.ints = player_details[:ints]
    end

    # Defaults if no value given
    player.username ||= 'testbot'
    player.flags ||= Set.new
    player.granted ||= Set.new
    player.withheld ||= Set.new
    player.missions ||= Set.new
    player.strings ||= {}
    player.ints ||= {}

    player
  end

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

    context 'when not given a username' do
      it 'raises an ArgumentError' do
        user_service = make_user_service()
        #noinspection RubyArgCount
        expect { user_service.get_user() }.to raise_error(ArgumentError)
      end
    end

    context 'when given a nil username' do
      it 'raises an ArgumentError' do
        user_service = make_user_service()
        expect { user_service.get_user(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when given a non-existant username' do
      it 'raises a ArgumentError' do
        player_data_service = PlayerDataService.new(File.dirname(__FILE__) + '/testusers')
        player_data_deserialiser = PlayerDataDeserialiser.new
        user_service = UserService.new(player_data_service, player_data_deserialiser)
        expect { user_service.get_user('nonexistantuser') }.to raise_error(ArgumentError)
      end
    end

    context 'when given a valid username' do
      subject(:user) do
        #noinspection RubyStringKeysInHashInspection
        user_options = {
            :flags => Set.new(%w(LoggedIn Colour NewNews)),
            :granted => Set.new(%w(Tester)),
            :withheld => Set.new(%w()),
            :missions => Set.new(%w(Academy Bandits Canister Dove Eviction Grain HolyGrail Hospital Invincible Ionstorm Kazimierz Legion Medical Mercury Recover Rescue Rogue Silo Skinner Tea sim:Combat1)),
            :strings =>
                        {
                          'password' => 'JBMg3fRi73o3.',
                          'owner' => 'level2_36',
                          'description' => "A description that
goes over a line and \" contains double quotes
",
                          'finger.email' => 'testbot@cryosphere.net'
                        },
            :ints => { 'level' => 20, '$transaction.2.amount' => -100, 'privs' => 999 }
                                         }
        user_service = make_user_service(user_options)
        user_service.get_user('testbot')
      end

      it 'returns a User object' do
        expect(user).to be_a_kind_of(User)
      end

      it 'sets username on the returned User' do
        expect(user.username).to eq('testbot')
      end

      it 'sets password on the returned User' do
        expect(user.password).to eq('JBMg3fRi73o3.')
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

    context 'when player has level >= 23 and does not have the SeeBugs pflag denied' do
      it 'returns true' do
        user_service = make_user_service()
        #noinspection RubyStringKeysInHashInspection
        player = make_player({ :ints => { 'privs' => 23 } })

        expect( user_service.send(:see_bugs?, player) ).to be_true
      end
    end
    context 'when player has level >= 23 and has the SeeBugs pflag denied' do
      it 'returns false' do
        user_service = make_user_service()
        #noinspection RubyStringKeysInHashInspection
        player = make_player({ :withheld => Set.new(%w(SeeBugs)), :ints => { 'privs' => 23 } })

        expect( user_service.send(:see_bugs?, player) ).to_not be_nil
        expect( user_service.send(:see_bugs?, player) ).to be_false
      end
    end
    context 'when player has level < 23 and does not have the SeeBugs pflag granted' do
      it 'returns false' do
        user_service = make_user_service()
        #noinspection RubyStringKeysInHashInspection
        player = make_player({ :ints => { 'level' => 22 } })


        expect( user_service.send(:see_bugs?, player) ).to_not be_nil
        expect( user_service.send(:see_bugs?, player) ).to be_false
      end
    end
    context 'when player has level < 23 and has the SeeBugs pflag granted' do
      it 'returns true' do
        user_service = make_user_service()
        #noinspection RubyStringKeysInHashInspection
        player = make_player({ :granted => Set.new(%w(SeeBugs)), :ints => { 'level' => 22 } })

        expect( user_service.send(:see_bugs?, player) ).to be_true
      end
    end
  end

  describe '#get_permission_level' do
    context 'when player has privs and level set' do
      it 'returns the value of privs' do
        user_service = make_user_service()
        player = make_player({ :ints => { 'level' => 23, 'privs' => 999 } })
        expect( user_service.send(:get_permission_level, player) ).to eq(999)
      end
    end
    context 'when player has privs but not level set' do
      it 'returns the value of privs' do
        user_service = make_user_service()
        player = make_player({ :ints => { 'privs' => 999 } })
        expect( user_service.send(:get_permission_level, player) ).to eq(999)
      end
    end
    context 'when player has level but not privs set' do
      it 'returns the value of level' do
        user_service = make_user_service()
        player = make_player({ :ints => { 'level' => 23 } })
        expect( user_service.send(:get_permission_level, player) ).to eq(23)
      end
    end
    context 'when player has neither level nor privs set' do
      it 'return zero' do
        user_service = make_user_service()
        player = make_player()
        expect( user_service.send(:get_permission_level, player) ).to eq(0)
      end
    end
  end

  describe '#banned?' do
    context 'when player has BugBanned flag' do
      it 'returns true' do
        user_service = make_user_service()
        player = make_player({ :flags => Set.new(%w(BugBanned)) })
        expect( user_service.send(:banned?, player) ).to be_true
      end
    end
    context 'when player does not have BugBanned flag' do
      it 'returns false' do
        user_service = make_user_service()
        player = make_player()
        expect( user_service.send(:banned?, player) ).to be_false
      end
    end
  end

end