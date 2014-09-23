require 'spec_helper'

describe 'relay register' do
  describe '/' do
    it 'should return valid response on GET' do
      get '/'

      expect(last_response).to be_ok
    end

    it 'should render index template on GET' do
      get '/'

      expect(last_response.body).to match(/relays/)
    end
  end
end
