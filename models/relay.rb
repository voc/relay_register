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
    RelayRegister::Parser::IP.extract_interfaces(self.ip_config)
  end

  def mount_points
    RelayRegister::Parser::DF.extract_df(self.disk_size)
  end
end
