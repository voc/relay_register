class Relay < ActiveRecord::Base

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
    interfaces = RelayRegister::Parser::IP.extract_interfaces(self.ip_config)
    interfaces.delete('lo')
    interfaces
  end

  def mount_points
    RelayRegister::Parser::DF.extract_df(self.disk_size)
  end

  def get_mac(interface_name = 'eth0')
    interfaces[interface_name]['mac']
  end

  def free_space
    sum = 0
    mount_points.each do |mount_point, values|
      sum += RelayRegister::Converter.convert_to_gb(values['size_available'])
    end

    "#{sum.round(1)}GB"
  end
end
