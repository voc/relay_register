class Relay < ActiveRecord::Base

  has_many :bandwiths
  has_and_belongs_to_many :tags, -> { uniq }
  before_save :default_master

  scope :public_relays,     -> { where(public: true) }
  scope :hidden_relays,     -> { where(public: false) }
  scope :visibility_groups, -> { group('public') }
  scope :one_host_tests,    -> { where(at_the_same_time: false) }

  def cpu_cores
    RelayRegister::Parser::CPU.count(self.cpu)
  end

  def cpu_model_name
    RelayRegister::Parser::CPU.model_name(self.cpu)
  end

  def total_memory
    RelayRegister::Parser::Free.total(self.memory)
  end

  def interfaces
    RelayRegister::Parser::IP.extract_interfaces(self.ip_config).tap do |interfaces|
      interfaces.delete('lo')
    end
  end

  def mount_points
    RelayRegister::Parser::DF.extract_df(self.disk_size)
  end

  def get_mac(interface_name = nil)
    if interface_name.nil?
      interfaces[interfaces.keys[0]]['mac']
    else
      interfaces[interface_name]['mac']
    end
  end

  def free_space
    sum = 0

    mount_points.each do |mount_point, values|
      sum += RelayRegister::Converter.convert_to_gb(values['size_available'])
    end

    "#{sum.round(1)}GB"
  end

  def rx
    sum      = 0.0
    bw_tests = bandwiths.where( at_the_same_time: false)

    bw_tests.each do |bw|
      sum += bw.rx
    end

    sum/bw_tests.count
  end

  def tx
    sum = 0.0
    bw_tests = bandwiths.where(at_the_same_time: false)

    bw_tests.each do |bw|
      sum += bw.tx
    end

    sum/bw_tests.count
  end

  def ips
    ips = []

    RelayRegister::Parser::IP.extract_interfaces(ip_config).each do |k, interface|
      %w{ipv4 ipv6}.each do |ip_version|
        interface["#{ip_version}"].compact.each do |ip|
          addr = IPAddr.new(ip.gsub(/\/\d+/, ''))
          unless addr.to_s =~ /fe80:|127\.0\.0\.|::1/
            ips << addr
          end
        end
      end
    end

    ips
  end

  def hostname_short
    hostname.split('.')[0..1].join('.')
  end

  def master_hostname
    master == "" ? "" : Relay.find(master).hostname
  end

  def hostname
    read_attribute(:hostname).chomp
  end

  protected

  def default_master
    self.master ||= ''
  end
end
