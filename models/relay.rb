require 'ipaddr'

class Relay < ActiveRecord::Base

  has_and_belongs_to_many :tags, -> { distinct }
  before_save :default_master

  scope :public_relays,     -> { where(public: true) }
  scope :hidden_relays,     -> { where(public: false) }
  scope :visibility_groups, -> { group('public') }
  scope :one_host_tests,    -> { where(at_the_same_time: false) }

  # Get CPU core count
  #
  # @return [Fixnum] cpu core count
  def cpu_cores
    RelayRegister::Parser::CPU.count(self.cpu)
  end

  # Get CPU name
  #
  # @return [String] cpu model name
  def cpu_model_name
    RelayRegister::Parser::CPU.model_name(self.cpu)
  end

  # Get memory
  #
  # @return [String] total memory
  def total_memory
    RelayRegister::Parser::Free.total(self.memory)
  end

  # Get all network interfaces
  #
  # @return [Hash] network interfaces without loopback interface
  def interfaces
    RelayRegister::Parser::IP.extract_interfaces(self.ip_config).tap do |interfaces|
      interfaces.delete('lo')
    end
  end

  # Get all mount points
  #
  # @return [Hash] mount points
  def mount_points
    RelayRegister::Parser::DF.extract_df(self.disk_size)
  end

  # Get mac address from defined interface
  #
  # @param interface_name [String] name of the interface
  # @return [String] mac address from first or defined interface
  def get_mac(interface_name = nil)
    if interface_name.nil?
      interfaces[interfaces.keys[0]]['mac']
    else
      interfaces[interface_name]['mac']
    end
  end

  # Get free disk space over all mount points
  #
  # @return [String] free disk space in GB
  def free_space
    sum = 0

    mount_points.each do |mount_point, values|
      sum += RelayRegister::Converter.convert_to_gb(values['size_available'])
    end

    "#{sum.round(1)} GB"
  end

  def rx
    sum      = 0.0
    bw_tests = bandwidths.where( at_the_same_time: false)

    bw_tests.each do |bw|
      sum += bw.rx
    end

    sum/bw_tests.count
  end

  def tx
    sum = 0.0
    bw_tests = bandwidths.where(at_the_same_time: false)

    bw_tests.each do |bw|
      sum += bw.tx
    end

    sum/bw_tests.count
  end

  # Get ip addresses
  #
  # @return [Array<IPAddr>] relays ip addresses
  def ips
    ips = []

    RelayRegister::Parser::IP.extract_interfaces(ip_config).each do |k, interface|
      %w{ipv4 ipv6}.each do |ip_version|
        interface["#{ip_version}"].compact.each do |ip|
          addr = IPAddr.new(ip.gsub(/\/\d+/, ''))
          unless addr.to_s =~ /^(fe80:|(fd|fc)[a-fA-F0-9]{2}:|127\.0\.0\.|::1)/
            ips << addr
          end
        end
      end
    end

    ips
  end

  # Return all configured public ips
  #
  # @return [Array<IPAdddr>]
  def public_ips
    public_ips = []

    ips.each do |ip|
      if ip.ipv6?
        public_ips << ip
      else
        next if [IPAddr.new("10.0.0.0/8"),
                 IPAddr.new("172.16.0.0/12"),
                 IPAddr.new("192.168.0.0/16")].any? {|i| i.include? ip}
        public_ips << ip
      end
    end
    #
    public_ips << IPAddr.new(ip) if public_ips.count == 0

    public_ips
  end

  # Get shorten fqdn hostname
  #
  # @return hostname [String] shorten
  def hostname_short
    hostname.split('.')[0..1].join('.')
  end

  # Get relay master hostname as string
  #
  # @return relay [String] as master hostname
  def master_hostname
    master == "" ? "" : Relay.find(master).hostname
  end

  # Get hostname without optinal separator
  #
  # @return hostname [String]
  def hostname
    read_attribute(:hostname).chomp
  end

  # Check relay for spezific ip address
  #
  # @param ip [IPAddr] you are looking for
  # @return [Boolean]
  def has_ip?(ip)
    ips.include?(ip)
  end

  # Return maximun of all defined priorities
  #
  # @return max_dns_priority [Fixnum]
  def self.max_dns_priority
    Relay.all.map(&:dns_priority).max
  end

  # Search relay by ip address
  #
  # @param ip [IPAddr] relay ip you are looking for
  # @return [Relay] relay or nil
  def self.find_by_ip(ip)
    Relay.all.each do |relay|
      return relay if relay.has_ip?(ip)
    end

    nil
  end

  protected

  def default_master
    self.master ||= ''
  end
end
