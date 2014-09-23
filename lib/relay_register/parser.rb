%w{cpu df free hostname ip}.each do |parser|
  require_relative "parser/#{parser}"
end

class RelayRegister
  class Parser
  end
end
