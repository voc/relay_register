require 'spec_helper'

describe 'RelayRegister' do

  before(:each) do
    @user     = @config['basic_auth']['user']
    @password = @config['basic_auth']['password']
  end

  describe '/' do
    it 'should return valid response on GET' do
      authorize @user, @password
      get '/'

      expect(last_response).to be_ok
    end

    it 'should render index template on GET' do
      authorize @user, @password

      get '/'
      expect(last_response.body).to match(/relays/)
    end

    it 'should be proteced with authentication' do
      get '/'

      expect(last_response.status).to be 401
    end
  end

  describe '/relay/:id' do
    it 'should return spezific relay on GET' do
      authorize @user, @password
      get '/relay/10'

      expect(last_response.body).to match(/.*<h2>127\.0\.0\.9\s-\sjihahihihi\..*<\/h2>/)
    end

    it 'should be proteced with authentication' do
      get '/relay/1'

      expect(last_response.status).to be 401
    end

    it 'should delete relay on DELETE' do
      authorize @user, @password
      delete '/relay/1'

      lambda {
        Relay.find(1)
      }.should raise_exception(ActiveRecord::RecordNotFound)
      expect(last_response.status).to be 302
    end
  end

  describe '/relay/:id/delete' do
    it 'should return delete page for a relay on GET' do
      authorize @user, @password
      get '/relay/10/delete'

      expect(last_response.body).to match(/delete\sjihahihihi/)
    end

    it 'should be proteced with authentication' do
      get '/relay/10/delete'

      expect(last_response.status).to be 401
    end
  end

  describe '/relay/:id/edit' do
    it 'should return spezific relay edit page on GET' do
      authorize @user, @password
      get '/relay/1/edit'

      expect(last_response.body).to match(/edit/)
    end

    it 'should return spezific edit page on GET' do
      authorize @user, @password
      get '/relay/10/edit'

      expect(last_response.status).to be 200
    end

    it 'should be proteced with authentication' do
      get '/relay/10/edit'

      expect(last_response.status).to be 401
    end
  end

  describe '/graph' do
    it 'should return graph page on GET' do
      authorize @user, @password
      get '/graph'

      expect(last_response.status).to be 200
    end

    it 'should be proteced with authentication' do
      get '/graph'

      expect(last_response.status).to be 401
    end
  end

  describe '/register' do
    before(:each) do
      @api_key = @config['api_key']
      @key     = @config['encryption_key']
      @iv      = OpenSSL::Cipher.new('aes-256-cbc').random_iv.unpack('H*')[0]

      @raw_data = {
        api_key: @api_key,
        raw_data: {
          hostname: `hostname -f`,
          lspci: `lspci`,
          ip_config: `ip a`,
          disk_size: `df -h`,
          memory: `free -m`,
          cpu: File.read('/proc/cpuinfo')
        }
      }.to_json

      @data = {
        iv: @iv,
        data: RelayRegister::AES.encrypt(@raw_data, @key, @iv)
      }.to_json
    end

    it 'should create new relay on POST' do
      post '/register', @data, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be 200
    end

    it 'should return 401 with wrong api_key on POST' do
      @raw_data['api_key'] = '1234'

      @data = {
        iv: @iv,
        data: RelayRegister::AES.encrypt(@raw_data, @key, @iv)
      }.to_json

      post '/register', @data, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be 401
    end

    it 'should return 401 status with wrong api_key data on POST' do
      pending
      post '/register'

      expect(last_response.status).to be 401
    end

    it 'should return 500 status with wrong encrypted data on POST' do
      post '/register', { iv: 'bla', data: 'möp' }
      expect(last_response.status).to be 500
    end
  end
end
