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

  describe '#get_filename' do
    it 'returns the filename for the given username' do
      player_service = PlayerService.new(File.dirname(__FILE__) + '/testusers')
      filename = player_service.send(:get_filename, 'testbot') # workaround for private method
      expected_filename = File.dirname(__FILE__) + '/testusers/testbot'
      expect(filename).to eq(expected_filename)
    end
  end
end