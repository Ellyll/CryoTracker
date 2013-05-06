require 'rspec'

describe AuthenticationService do
  describe '#initialize' do
    context 'when not given a directory path' do
      it 'raises an ArgumentError' do
        expect { AuthenticationService.new }.to raise_error(ArgumentError)
        expect { AuthenticationService.new(nil) }.to raise_error(ArgumentError)
      end
    end
    context 'when given a directory path that is not a directory' do
       it 'raises an ArgumentError' do
         filename = File.dirname(__FILE__) + '/non_existant_directory'
         expect { AuthenticationService.new(filename) }.to raise_error(ArgumentError)
       end
    end
  end

  describe '#is_authenticated?' do
    auth_serv = AuthenticationService.new(File.dirname(__FILE__) + '/testusers')
    context 'when given a nil username and password' do
      it 'returns false' do
        auth_serv.is_authenticated?(nil,nil).should be_false
      end
    end
    context 'when given an invalid username and password' do
      it 'returns false' do
        auth_serv.is_authenticated?('', '').should be_false
        auth_serv.is_authenticated?('x', 'x').should be_false
        auth_serv.is_authenticated?('testbot', 'x').should be_false
        auth_serv.is_authenticated?('testbot', '').should be_false
        auth_serv.is_authenticated?('testbot', nil).should be_false
        auth_serv.is_authenticated?('', 'mmmhufenia').should be_false
        auth_serv.is_authenticated?(nil, 'mmmhufenia').should be_false
      end
    end
    context 'when given an valid username and password' do
      it 'returns true' do
        auth_serv.is_authenticated?('testbot', 'mmmhufenia').should be_true
      end
    end
  end
end