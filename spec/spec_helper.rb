# First include simplecov to track code coverage
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

require 'rspec'
require 'rack/test'
require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

%w{parser aes converter mqtt}.each do |file|
  require File.join(File.dirname(__FILE__), '..', 'lib', 'relay_register', "#{file}.rb")
end

%w{relay}.each do |file|
  require File.join(File.dirname(__FILE__), '..', 'models', "#{file}.rb")
end

%w{cpu df free ip}.each do |file|
  require File.join(File.dirname(__FILE__), '..', 'lib', 'relay_register', 'parser', "#{file}.rb")
end

require File.join(File.dirname(__FILE__), '..', 'webapp.rb')

# Create sqlite database and loead db schema
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Base.logger = nil
load "#{File.expand_path('../..', __FILE__)}/db/schema.rb"

# Configure rspec
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.color = true
  config.order = 'random'

  config.before(:each) do
    @spec_root    = File.expand_path('..', __FILE__)
    @project_root = File.expand_path('..', @spec_root)
    @config       = YAML.load(Pathname(@project_root + '/settings.yml.example').read)
  end
end

10.times do |t|
  Relay.find_or_create_by(
    ip: "127.0.0.#{t}",
    mac: 'aa:bb:cc:dd:ee',
    hostname: "jihahihihi.magrathea.3st.be\n",
    ip_config: "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default \n    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00\n    inet 127.0.0.1/8 scope host lo\n       valid_lft forever preferred_lft forever\n    inet6 ::1/128 scope host \n       valid_lft forever preferred_lft forever\n2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000\n    link/ether 00:1f:16:0e:03:2b brd ff:ff:ff:ff:ff:ff\n    inet 192.168.0.103/24 brd 192.168.0.255 scope global eth0\n       valid_lft forever preferred_lft forever\n    inet6 fe80::21f:16ff:fe0e:32b/64 scope link \n       valid_lft forever preferred_lft forever\n3: wlan0: <BROADCAST,MULTICAST> mtu 1500 qdisc mq state DOWN group default qlen 1000\n    link/ether 00:21:5d:8b:81:30 brd ff:ff:ff:ff:ff:ff\n4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default \n    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff\n    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0\n       valid_lft forever preferred_lft forever\n",
    disk_size: "Filesystem               Size  Used Avail Use% Mounted on\n/dev/mapper/system-root  2.0G  1.8G   28K 100% /\ndev                      3.9G     0  3.9G   0% /dev\nrun                      3.9G   11M  3.9G   1% /run\n/dev/mapper/system-usr    15G  9.6G  4.4G  70% /usr\ntmpfs                    3.9G   76M  3.8G   2% /dev/shm\ntmpfs                    3.9G     0  3.9G   0% /sys/fs/cgroup\n/dev/sda2                190M   40M  136M  23% /boot\n/dev/mapper/system-tmp   4.0G  273M  3.5G   8% /tmp\n/dev/mapper/system-opt   2.9G  1.8G  975M  66% /opt\n/dev/mapper/system-var    15G   12G  2.3G  84% /var\n/dev/mapper/system-home   71G   69G  2.0G  98% /home\ntmpfs                    789M   28K  789M   1% /run/user/1000\nencfs                    819G  757G   21G  98% /mnt/encfs\nencfs                     71G   69G  2.0G  98% /mnt/privat\n/dev/sdb2                819G  757G   21G  98% /mnt/usb\n",
    cpu: "processor\t: 0\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 23\nmodel name\t: Intel(R) Core(TM)2 Duo CPU     P8400  @ 2.26GHz\nstepping\t: 6\nmicrocode\t: 0x60c\ncpu MHz\t\t: 2267.000\ncache size\t: 3072 KB\nphysical id\t: 0\nsiblings\t: 2\ncore id\t\t: 0\ncpu cores\t: 2\napicid\t\t: 0\ninitial apicid\t: 0\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 10\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 lahf_lm dtherm tpr_shadow vnmi flexpriority\nbogomips\t: 4523.14\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 36 bits physical, 48 bits virtual\npower management:\n\nprocessor\t: 1\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 23\nmodel name\t: Intel(R) Core(TM)2 Duo CPU     P8400  @ 2.26GHz\nstepping\t: 6\nmicrocode\t: 0x60c\ncpu MHz\t\t: 2267.000\ncache size\t: 3072 KB\nphysical id\t: 0\nsiblings\t: 2\ncore id\t\t: 1\ncpu cores\t: 2\napicid\t\t: 1\ninitial apicid\t: 1\nfpu\t\t: yes\nfpu_exception\t: yes\ncpuid level\t: 10\nwp\t\t: yes\nflags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts nopl aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 lahf_lm dtherm tpr_shadow vnmi flexpriority\nbogomips\t: 4523.14\nclflush size\t: 64\ncache_alignment\t: 64\naddress sizes\t: 36 bits physical, 48 bits virtual\npower management:\n\n",
    lspci: "00:00.0 Host bridge: Intel Corporation Mobile 4 Series Chipset Memory Controller Hub (rev 07)\n00:02.0 VGA compatible controller: Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller (rev 07)\n00:02.1 Display controller: Intel Corporation Mobile 4 Series Chipset Integrated Graphics Controller (rev 07)\n00:03.0 Communication controller: Intel Corporation Mobile 4 Series Chipset MEI Controller (rev 07)\n00:03.2 IDE interface: Intel Corporation Mobile 4 Series Chipset PT IDER Controller (rev 07)\n00:03.3 Serial controller: Intel Corporation Mobile 4 Series Chipset AMT SOL Redirection (rev 07)\n00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network Connection (rev 03)\n00:1a.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #4 (rev 03)\n00:1a.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #5 (rev 03)\n00:1a.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #6 (rev 03)\n00:1a.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #2 (rev 03)\n00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio Controller (rev 03)\n00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 1 (rev 03)\n00:1c.1 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 2 (rev 03)\n00:1c.3 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Express Port 4 (rev 03)\n00:1d.0 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #1 (rev 03)\n00:1d.1 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #2 (rev 03)\n00:1d.2 USB controller: Intel Corporation 82801I (ICH9 Family) USB UHCI Controller #3 (rev 03)\n00:1d.7 USB controller: Intel Corporation 82801I (ICH9 Family) USB2 EHCI Controller #1 (rev 03)\n00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev 93)\n00:1f.0 ISA bridge: Intel Corporation ICH9M-E LPC Interface Controller (rev 03)\n00:1f.2 SATA controller: Intel Corporation 82801IBM/IEM (ICH9M/ICH9M-E) 4 port SATA Controller [AHCI mode] (rev 03)\n00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev 03)\n03:00.0 Network controller: Intel Corporation PRO/Wireless 5100 AGN [Shiloh] Network Connection\n",
    memory: "             total       used       free     shared    buffers     cached\nMem:          7880       7636        244        223        700       4450\n-/+ buffers/cache:       2486       5394\nSwap:         8191         21       8170\n"
  ).save
end

def app
  Sinatra::Application
end
