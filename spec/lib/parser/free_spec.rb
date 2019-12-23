require 'spec_helper'

describe RelayRegister::Parser::Free do

  before(:each) do
    @free =<<END
             total       used       free     shared    buffers     cached\nMem:          7880       7755        125        338        590       4559\n-/+ buffers/cache:       2606       5274\nSwap:         8191         21       8170\n
END
  end

  describe '.total' do
    it 'should return total memory' do
      total = RelayRegister::Parser::Free.total(@free)
      expect(total).to eq('7.7 GB')
    end
  end

  describe '.readable_size' do
    it 'should convert size in MB to human readable GB' do
      total = RelayRegister::Parser::Free.readable_size(4242)
      expect(total).to eq('4.14 GB')
    end

    it 'should convert size in MB to human readable MB' do
      total = RelayRegister::Parser::Free.readable_size(512)
      expect(total).to eq('512.0 MB')
    end
  end
end
