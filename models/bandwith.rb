class Bandwith < ActiveRecord::Base
  belongs_to :relay

  scope :default, -> { where(is_deleted: false) }

  def tx
    split_iperf.each do |iperf|
      split = iperf.split(',')

      if split[3] =~ /#{destination}/
        return split[8].to_i
      end
    end
  end

  def rx
    split_iperf.each do |iperf|
      split = iperf.split(',')

      if split[1] =~ /#{destination}/
        return split[8].to_i
      end
    end

    0
  end

  def self.normalize(nr)
    nr = nr.to_f
    if nr.to_s.split('.')[0].length <= 9
      "#{(nr/1000/1000).round(2)} Mbps"
    else
      "#{(nr/1000/1000/1000).round(2)} Gbps"
    end
  end

  protected

  def split_iperf
    iperf.split('\n')
  end
end
