class RelayRegister
  class Converter
    # Convert df size string to GB
    # @example Convert 2342M
    #   Converter.convert_to_gb('2342M') => 2
    #
    # @param string [String] to convert to GB
    # @return [Fixnum] converted number
    def self.convert_to_gb(string)
      number = string.gsub(/[a-zA-Z]+/, '').to_f

      case string.match(/K|M|G|T/)[0]
      when 'K'
        number/1024/1024
      when 'M'
        number/1024
      when 'G'
        number
      when 'T'
        number*1024
      end
    end
  end
end
