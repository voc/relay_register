class Bandwith < ActiveRecord::Base
  belongs_to :relay

  scope :default, -> { where(is_deleted: false) }

  def tx
    # TODO: do not catch exception just handle it the right way
    begin
      split_iperf.each do |iperf|
        split = iperf.split(/\n/)[0].split(',')

        if split[3] =~ /#{destination}/
          return split[8].to_i
        end
      end
    rescue
      0
    end
  end

  def rx
    # TODO: do not catch exception just handle it the right way
    begin
      split_iperf.each do |iperf|
        split = iperf.split(/\n/)[1].split(',')

        if split[3] =~ /#{destination}/
          return split[8].to_i
        end
      end
    rescue
      0
    end
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
