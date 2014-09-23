require 'spec_helper'

describe RelayRegister::Parser::DF do

  before(:each) do
    @df =<<END
    "Filesystem               Size  Used Avail Use% Mounted
on\n/dev/mapper/system-root  2.0G   20M  1.8G   2% /\ndev
    3.9G     0  3.9G   0% /dev\nrun                      3.9G   10M  3.9G   1%
      /run\n/dev/mapper/system-usr    15G  9.5G  4.5G  69% /usr\ntmpfs
    3.9G  226M  3.7G   6% /dev/shm\ntmpfs                    3.9G     0  3.9G
    0% /sys/fs/cgroup\n/dev/sda2                190M   40M  136M  23%
      /boot\n/dev/mapper/system-tmp   4.0G  275M  3.5G   8%
      /tmp\n/dev/mapper/system-opt   2.9G  1.8G  975M  66%
      /opt\n/dev/mapper/system-var    15G   11G  3.2G  78%
      /var\n/dev/mapper/system-home   71G   67G  3.9G  95% /home\ntmpfs
    789M   24K  789M   1% /run/user/1000\nencfs                    819G  717G
    61G  93% /mnt/encfs\n/dev/sdb2                819G  717G   61G  93%
      /mnt/usb\n"
END
  end

  describe '.ordered' do
    it 'should remove not needed mount points' do
      count = RelayRegister::Parser::CPU.count(@cpu_info)
      expect(count).to eq(2)
    end
  end
end
