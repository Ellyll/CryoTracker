require 'rspec'
require_relative '../../services/player_data_deserialiser'

describe PlayerDataDeserialiser do
  player_data = <<EOF
mudobject "testbot" {
flags LoggedIn Colour NewNews
granted Tester
withheld SeeBugs
mission Academy Bandits Canister Dove Eviction Grain HolyGrail Hospital Invincible Ionstorm Kazimierz Legion Medical Mercury Recover Rescue Rogue Silo Skinner Tea sim:Combat1
string owner "level2_36"
string description "A description that
goes over a line and \\" contains double quotes
"
string finger.email "testbot@cryosphere.net"
int level 20
int $transaction.2.amount -100
}
EOF

  describe '.deserialise' do
    player_data_deserialiser = PlayerDataDeserialiser.new
    player = player_data_deserialiser.deserialise(player_data)

    it 'returns a Player object' do
      expect(player).to be_a(Player)
    end

    it 'sets username on returned Player' do
      expect(player.username).to eq('testbot')
    end

    it 'sets flags on returned Player' do
      expected_flags = Set.new(%w(LoggedIn Colour NewNews))
      expect(player.flags).to eq(expected_flags)
    end

    it 'sets granted on returned Player' do
      expected_granted = Set.new(%w(Tester))
      expect(player.granted).to eq(expected_granted)
    end

    it 'sets withheld on returned Player' do
      expected_withheld = Set.new(%w(SeeBugs))
      expect(player.withheld).to eq(expected_withheld)
    end

    it 'sets missions on returned Player' do
      expected_missions = Set.new(%w(Tester))
      expect(player.granted).to eq(expected_missions)
    end

    it 'sets strings on returned Player' do
      expect(player.strings['finger.email']).to eq('testbot@cryosphere.net')
    end

    it 'sets ints on returned Player' do
      expect(player.ints['level']).to eq(20)
      expect(player.ints['$transaction.2.amount']).to eq(-100) # Check can handle negative values
    end

    it 'raises PlayerDataDeserialiserError if player data does not contain mudobject in header' do
      expect { player_data_deserialiser.deserialise('this is some invalid data') }.to raise_error(PlayerDataDeserialiserError)
    end
  end

  # private

  describe '.read_header' do
    player_data_deserialiser = PlayerDataDeserialiser.new
    index, header_type, header_name = player_data_deserialiser.read_header(player_data, 0)

    it 'updates the index' do
      expect(index).to be > 0
    end

    it 'reads the header type' do
      expect(header_type).to eq('mudobject')
    end
    it 'reads the header name' do
      expect(header_name).to eq('testbot')
    end

    it 'raises a PlayerDataDeserialiserError if a newline is encountered after reading header type' do
      expect { player_data_deserialiser.read_header("mudobject\n", 0) }. to raise_error(PlayerDataDeserialiserError)
    end

    it 'raises a PlayerDataDeserialiserError if an opening { is not found while reading header' do
      expect { player_data_deserialiser.read_header("mudobject \"someuser\"\n", 0) }. to raise_error(PlayerDataDeserialiserError)
    end
  end

  describe '.read_body' do
    player_data_deserialiser = PlayerDataDeserialiser.new
    index, flags, granted, withheld, missions, strings, ints = player_data_deserialiser.read_body(player_data,22)

    it 'updates the index' do
      expect(index).to be > 22
    end

    it 'reads the flags' do
      expect(flags).to include('LoggedIn','Colour', 'NewNews')
    end

    it 'reads the granted flags' do
      expect(granted).to include('Tester')
    end

    it 'reads the widthheld flags' do
      expect(withheld).to include('SeeBugs')
    end

    it 'reads the mission flags' do
      expect(missions).to include('Academy', 'sim:Combat1')
    end

    it 'reads the string values' do
      expect(strings).to_not be_empty
      expect(strings['owner']).to eq('level2_36')
      expect(strings['description']).to end_with("contains double quotes\n")
    end

    it 'reads the int values' do
      expect(ints).to_not be_empty
      expect(ints['level']).to eq(20)
    end

    it 'raises a PlayerDataDeserialiserError if an unrecognised data type is encountered' do
      expect { player_data_deserialiser.read_body("unknowndatatype 123\n", 0) }. to raise_error(PlayerDataDeserialiserError)
    end
  end
end