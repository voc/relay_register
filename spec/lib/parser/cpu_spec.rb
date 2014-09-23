require 'spec_helper'

describe RelayRegister::Parser::CPU do

  before(:each) do
    @cpu_info =<<END
processor\t: 0\nvendor_id\t: GenuineIntel\ncpu family\t:
6\nmodel\t\t: 23\nmodel name\t: Intel(R) Core(TM)2 Duo CPU     P8400  @
2.26GHz\nstepping\t: 6\nmicrocode\t: 0x60c\ncpu MHz\t\t: 1600.000\ncache
size\t: 3072 KB\nphysical id\t: 0\nsiblings\t: 2\ncore id\t\t: 0\ncpu
cores\t: 2\napicid\t\t: 0\ninitial apicid\t: 0\nfpu\t\t:
  yes\nfpu_exception\t: yes\ncpuid level\t: 10\nwp\t\t: yes\nflags\t\t: fpu
vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush
dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc
arch_perfmon pebs bts rep_good nopl aperfmperf pni dtes64 monitor ds_cpl vmx
smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 lahf_lm dtherm tpr_shadow vnmi
flexpriority\nbogomips\t: 4523.14\nclflush size\t: 64\ncache_alignment\t:
  64\naddress sizes\t: 36 bits physical, 48 bits virtual\npower
management:\n\nprocessor\t: 1\nvendor_id\t: GenuineIntel\ncpu family\t:
  6\nmodel\t\t: 23\nmodel name\t: Intel(R) Core(TM)2 Duo CPU     P8400  @
2.26GHz\nstepping\t: 6\nmicrocode\t: 0x60c\ncpu MHz\t\t: 1600.000\ncache
size\t: 3072 KB\nphysical id\t: 0\nsiblings\t: 2\ncore id\t\t: 1\ncpu
cores\t: 2\napicid\t\t: 1\ninitial apicid\t: 1\nfpu\t\t:
  yes\nfpu_exception\t: yes\ncpuid level\t: 10\nwp\t\t: yes\nflags\t\t: fpu
vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush
dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc
arch_perfmon pebs bts nopl aperfmperf pni dtes64 monitor ds_cpl vmx smx est
tm2 ssse3 cx16 xtpr pdcm sse4_1 lahf_lm dtherm tpr_shadow vnmi
flexpriority\nbogomips\t: 4523.14\nclflush size\t: 64\ncache_alignment\t:
  64\naddress sizes\t: 36 bits physical, 48 bits virtual\npower
management:\n\n"
END
  end

  describe '.count' do
    it 'should count the number of cores' do
      count = RelayRegister::Parser::CPU.count(@cpu_info)
      expect(count).to eq(2)
    end
  end

  describe '.model_name' do
    it 'should return cpu model name' do
      model_name = RelayRegister::Parser::CPU.model_name(@cpu_info)
      expect(model_name).to match(/P8400/)
    end
  end
end
