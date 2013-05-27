require 'rspec'
require_relative '../../models/user'

describe User do

  attributes = [
                :username,
                :password,
                :email_address,
                :banned?,
                :able_to_see_others_bugs?
               ]
  attributes.each do |attrib|
    it "responds to #{attrib.to_s}" do
      user = User.new
      expect(user).to respond_to(attrib)
    end
  end

  describe '#password_matches?' do
    user = User.new
    user.password = 'JBMg3fRi73o3.'
    # note that only first 8 chars are relevant in crypt() :(

    context 'when given a nil password' do
      it 'returns false' do
        expect(user.password_matches?(nil)).to be_false
      end
    end

    context 'when given an empty password' do
      it 'returns false' do
        expect(user.password_matches?('')).to be_false
      end
    end

    context 'when given a password that does not match' do
      it 'returns false' do
        expect(user.password_matches?('JBMg3fRi73o3X')).to be_false
      end
    end

    context 'when given a password that matches' do
      it 'returns true' do
        expect(user.password_matches?('mmmhufenia')).to be_true
      end
    end
  end

end