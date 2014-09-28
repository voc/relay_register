require 'spec_helper'

describe RelayRegister::Mqtt do

  before(:each) do
    @relay = Relay.last
  end

  describe '.send_message' do
    it 'should send a mqtt message to given host' do
      pending('not yet implemented')
      this_should_not_get_executed
    end
  end

  describe '.generate_message_for_humans' do
    it 'should convert relay information to human readable mqtt message' do
      data = RelayRegister::Mqtt.generate_message_for_humans(@relay)

      expect(data['component']).not_to be nil
      expect(data['msg']).not_to be nil
      expect(data['level']).to match(/info|warn/)
    end
  end

  describe '.generate_message_for_robots' do
    it 'should convert relay information mqtt message for robots' do
      pending('not yet implemented')
      this_should_not_get_executed
    end
  end
end
