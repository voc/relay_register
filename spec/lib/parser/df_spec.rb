require 'spec_helper'

describe RelayRegister::Parser::DF do

  before(:each) do
    @df =<<END
Filesystem              1K-blocks      Used Available Use% Mounted on\n/dev/mapper/system-root   1998672   1877404        28 100% /\ndev                       4030924         0   4030924   0% /dev\nrun                       4034960     10308   4024652   1% /run\n/dev/mapper/system-usr   15350768  10150592   4397360  70% /usr\ntmpfs                     4034960    174844   3860116   5% /dev/shm\ntmpfs                     4034960         0   4034960   0% /sys/fs/cgroup\n/dev/sda2                  194241     40839    139066  23% /boot\n/dev/mapper/system-tmp    4095680    332356   3568692   9% /tmp\n/dev/mapper/system-opt    3030800   1870124    997496  66% /opt\n/dev/mapper/system-var   15350768  11471680   3076272  79% /var\n/dev/mapper/system-home  74181832  71405908   2025540  98% /home\ntmpfs                      806992        28    806964   1% /run/user/1000\nencfs                   858089544 793266876  21211124  98% /mnt/encfs\nencfs                    74181832  71405908   2025540  98% /mnt/privat\n/dev/sdb2               858089544 793266876  21211124  98% /mnt/usb\n
END
  end

  describe '.extract_df' do
    it 'should return mount points' do
      mount_points = RelayRegister::Parser::DF.extract_df(@df)
      expect(mount_points.count).to eq(10)
      expect(mount_points['/home']['size_total']).to eq('74181832')
    end

    it 'should remove not needed mount mounts' do
      mount_points = RelayRegister::Parser::DF.extract_df(@df)
      expect(mount_points['dev']).to be nil
      expect(mount_points['run']).to be nil
    end

    it 'should return a hash' do
      class_name = RelayRegister::Parser::DF.extract_df(@df).class
      expect(class_name).to be Hash
    end
  end
end
