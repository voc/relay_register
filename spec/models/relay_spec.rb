require 'spec_helper'

describe Relay do

  before(:each) do
    @relay = Relay.last
  end

  describe '#cpu_cores' do
    it 'should return number of cpu cores' do
      core_count = @relay.cpu_cores
      expect(core_count).to eq(2)
    end
  end

  describe '#cpu_model_name' do
    it 'should return cpu name' do
      cpu_model_name = @relay.cpu_model_name
      expect(cpu_model_name).to eq('Intel(R) Core(TM)2 Duo CPUP8400@ 2.26GHz')
    end
  end

  describe '#total_memory' do
    it 'should return totel memory' do
      total_memory = @relay.total_memory
      expect(total_memory).to eq('7.7GB')
    end
  end

  describe '#mount_points' do
    it 'should return all mount points' do
      mount_points = @relay.mount_points
      expect(mount_points.count).to eq(10)
    end
  end

  describe '#free_space' do
    it 'should calculte free disk space' do
      free_space = @relay.free_space
      expect(free_space).to eq('57.3GB')
    end
  end

  describe '#get_mac' do
    it 'should mac for given interface' do
      eth0_mac  = @relay.get_mac
      wlan0_mac = @relay.get_mac('wlan0')

      expect(eth0_mac).to eq('00:1f:16:0e:03:2b')
      expect(wlan0_mac).to eq('00:21:5d:8b:81:30')
    end
  end
end
