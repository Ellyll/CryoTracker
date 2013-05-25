require 'rspec'
require_relative '../../services/player_data_serialiser'
require_relative '../../models/player'

describe PlayerDataSerialiser do

  describe '.serialise' do
    serialiser = PlayerDataSerialiser.new

    context 'when not given a valid Player object' do
      it 'raises an ArgumentError' do
        #noinspection RubyArgCount
        expect { serialiser.serialise() }.to raise_error(ArgumentError)
        expect { serialiser.serialise(nil) }.to raise_error(ArgumentError)
        expect { serialiser.serialise(Object.new) }.to raise_error(ArgumentError)
      end
    end

    context 'when given a valid Player object' do
      subject(:player_data) do
        player = Player.new
        player.username = 'testbot'
        player.flags = Set.new(%w(LoggedIn Colour NewNews))
        player.granted = Set.new(%w(Tester))
        player.withheld = Set.new(%w(SeeBugs))
        player.missions = Set.new(%w(Academy Bandits Canister Dove Eviction Grain HolyGrail Hospital Invincible Ionstorm Kazimierz Legion Medical Mercury Recover Rescue Rogue Silo Skinner Tea sim:Combat1))
        #noinspection RubyStringKeysInHashInspection
        player.strings =
            {
                'owner' => 'level2_36',
                'description' => "A description that
goes over a line and \" contains double quotes
",
                'finger.email' => 'testbot@cryosphere.net'
            }
        #noinspection RubyStringKeysInHashInspection
        player.ints = { 'level' => 20, '$transaction.2.amount' => -100 }

        serialiser.serialise(player)
      end

      it 'returns a non-empty string' do
        expect(player_data).to be_a_kind_of(String)
        expect(player_data.gsub(/\s/, '')).to_not be_empty
      end

      it 'serialises username' do
        expect(player_data).to match(/^mudobject testbot {\n/)
      end

      it 'serialises flags' do
        expect(player_data).to match(/\nflags LoggedIn Colour NewNews\n/)
      end

      it 'serialises granted' do
        expect(player_data).to match(/\ngranted Tester\n/)
      end

      it 'serialises withheld' do
        expect(player_data).to match(/\nwithheld SeeBugs\n/)
      end

      it 'serialises missions' do
        expect(player_data).to match(/\nmission Academy Bandits Canister Dove Eviction Grain HolyGrail Hospital Invincible Ionstorm Kazimierz Legion Medical Mercury Recover Rescue Rogue Silo Skinner Tea sim:Combat1\n/)
      end

      it 'serialises strings' do
        expect(player_data).to match(/\nstring owner "level2_36"\n/)
        expect(player_data).to match(/\nstring description "A description that
goes over a line and \\" contains double quotes\n"/)
      end

      it 'serialises ints' do
        expect(player_data).to match(/\nint level 20\n/)
        expect(player_data).to match(/\nint \$transaction.2.amount -100\n/)
      end
    end
  end
end