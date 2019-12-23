require 'spec_helper'

describe RelayRegister::Mqtt do

  before(:each) do
    @relay = Relay.last
  end

  describe '.generate_message_for_humans' do
    it 'should convert relay information to human readable mqtt message' do
      data = RelayRegister::Mqtt.generate_message_for_humans('https://foo.bar/', @relay)

      expect(data['component']).not_to be nil
      expect(data['msg']).not_to be nil
      expect(data['level']).to match(/info|warn/)
    end
  end
end
