require 'spec_helper'

describe RelayRegister::Converter do
  describe '.convert_to_gb' do
    it 'should convert size as string to number in GB' do
      data = RelayRegister::Converter.convert_to_gb('2342M')
      expect(data).to eq(2.287109375)
    end
  end
end
