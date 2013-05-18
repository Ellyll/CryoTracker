require 'rspec'
require_relative '../../services/player_data_service'

describe PlayerDataService do
  describe '#initialize' do
    context 'when not given a directory path' do
      it 'raises an ArgumentError' do
        #noinspection RubyArgCount
        expect { PlayerDataService.new }.to raise_error(ArgumentError)
        expect { PlayerDataService.new(nil) }.to raise_error(ArgumentError)
      end
    end
    context 'when given a directory path that is not a directory' do
      it 'raises an ArgumentError' do
        directory_name = File.dirname(__FILE__) + '/non_existant_directory'
        expect { PlayerDataService.new(directory_name) }.to raise_error(ArgumentError)
      end
    end

    context 'when given a valid directory path' do
      it 'sets @user_files_directory to the given path' do
        directory_name = File.dirname(__FILE__) + '/testusers'
        player_data_service = PlayerDataService.new(directory_name)
        expect(player_data_service.user_files_directory).to eq(directory_name)
      end
    end
  end

  describe '#get_player_data' do
    directory_name = File.dirname(__FILE__) + '/testusers'
    player_data_service = PlayerDataService.new(directory_name)

    context 'when not given a username' do
      it 'raises an ArgumentError' do
        #noinspection RubyArgCount
        expect { player_data_service.get_player_data() }.to raise_error(ArgumentError)
      end
    end

    context 'when given a nil username' do
      it 'raises an ArgumentError' do
        expect { player_data_service.get_player_data(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when given a username in an invalid format' do
      it 'raises an ArgumentError' do
        invalid_username = '_\$%#"!.,,"'
        expect { player_data_service.get_player_data(invalid_username) }.to raise_error(ArgumentError)
      end
    end

    context 'when given a non-existant username' do
      it 'raises an ArgumentError' do
        non_existant_username = 'nonexistantusername'
        expect { player_data_service.get_player_data(non_existant_username) }.to raise_error(ArgumentError)
      end
    end

    context 'when given a valid username' do
      it 'gets the player data' do
        valid_username = 'testbot'
        player_data = player_data_service.get_player_data(valid_username)
        expect(player_data).to_not be_nil
        expect(player_data).to_not be_empty
      end
    end
  end
end