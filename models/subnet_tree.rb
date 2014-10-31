require 'radix'

class SubnetTree

  def initialize(csv_path)
    @tree = Radix.new

    build_tree(csv_path)
  end

  def search(subnet)
    node = @tree.search_best(subnet)

    node.nil? ? {asn: '', name: ''} : node.msg
  end

  def build_tree(file)
    File.open(Pathname.pwd + file, 'r:iso-8859-1').each_line do |line|
      prefix, asn, name = line.split(';')
      name              = name.encode('iso-8859-1').encode('UTF-8').chomp

      @tree.add(prefix)
      @tree[prefix] = {asn: asn, name: name }
    end
  end
end
