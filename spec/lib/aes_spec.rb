require 'spec_helper'

describe RelayRegister::AES do

  before(:each) do
    @iv   = OpenSSL::Cipher.new('aes-256-cbc').random_iv.unpack('H*')[0]
    @data = 'My plain text data!!1!'
    @key  = @config['encryption_key']
  end

  describe '.decrypt' do
    it 'should decrypt data with given key and iv' do
      encrypted_data = RelayRegister::AES.encrypt(@data, @key, @iv)
      decrypted_data = RelayRegister::AES.decrypt(encrypted_data, @key, @iv)
      expect(decrypted_data).to eq(@data)
    end
  end

  describe '.encrypt' do
    it 'should encrypt data with given key and iv' do
      data = RelayRegister::AES.encrypt(@data, @key, @iv)
      expect(data).not_to be eq(@data)
    end

    it 'should return base64 encoded data' do
      data = RelayRegister::AES.encrypt(@data, @key, @iv)
      expect(data).to match(/^([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{4}|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==)$/)
    end

    it 'should not just base64 encode' do
      data = RelayRegister::AES.encrypt(@data, @key, @iv)
      expect(Base64.encode64(@data)).not_to eq(@data)
    end
  end
end
