require 'spec_helper'

describe RelayRegister::Parser::IP do

  before(:each) do
    @ip =<<END
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default \n    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00\n    inet 127.0.0.1/8 scope host lo\n       valid_lft forever preferred_lft forever\n    inet6 ::1/128 scope host \n       valid_lft forever preferred_lft forever\n2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000\n    link/ether 00:1f:16:0e:03:2b brd ff:ff:ff:ff:ff:ff\n    inet 192.168.0.103/24 brd 192.168.0.255 scope global eth0\n       valid_lft forever preferred_lft forever\n    inet6 fe80::21f:16ff:fe0e:32b/64 scope link \n       valid_lft forever preferred_lft forever\n3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN group default qlen 1000\n    link/ether 00:21:5d:8b:81:30 brd ff:ff:ff:ff:ff:ff\n4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default \n    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff\n    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0\n       valid_lft forever preferred_lft forever\n
END
  end

  describe '.extract_interfaces' do
    it 'should return all interfaces' do
      interfaces = RelayRegister::Parser::IP.extract_interfaces(@ip)
      expect(interfaces.count).to eq(4)
      expect(interfaces['eth0']).not_to be nil
      expect(interfaces['lo']).not_to be nil
      expect(interfaces['virbr0']).not_to be nil
      expect(interfaces['wlan0']).not_to be nil
    end

    it 'should found all IPv4 addresses to an interface' do
      interfaces = RelayRegister::Parser::IP.extract_interfaces(@ip)
      eth0 = interfaces['eth0']
      expect(eth0['ipv4'].first).to eq('192.168.0.103/24')
    end

    it 'should found all IPv6 addresses to an interface' do
      interfaces = RelayRegister::Parser::IP.extract_interfaces(@ip)
      eth0 = interfaces['eth0']
      expect(eth0['ipv6'][0]).to eq('fe80::21f:16ff:fe0e:32b/64')
    end

    it 'should found mac address of an interface' do
      interfaces = RelayRegister::Parser::IP.extract_interfaces(@ip)
      eth0 = interfaces['eth0']
      expect(eth0['mac']).to eq('00:1f:16:0e:03:2b')
    end

    it 'should return a hash' do
      class_name = RelayRegister::Parser::IP.extract_interfaces(@ip).class
      expect(class_name).to be Hash
    end
  end
end
