require 'radix'

class SubnetTree
  # Create SubentTree object
  #
  # @param csv_path [String] path to csv file
  def initialize(csv_path)
    @tree = Radix.new

    build_tree(csv_path)
  end

  # Search for as name and asn
  #
  # @param subnet [String] subent
  # @return [Hash] with asn and name
  def search(subnet)
    node = @tree.search_best(subnet)

    if node.nil?
      {asn: '', name: ''}
    else
      node.msg
    end
  end

  # Build new as tree from csv file
  #
  # @param csv_path [String] path to csv file
  def build_tree(file)
    File.open(Pathname.pwd + file, 'r:iso-8859-1').each_line do |line|
      prefix, asn, name = line.split(';')
      name              = name.encode('iso-8859-1').encode('UTF-8').chomp

      @tree.add(prefix)
      @tree[prefix] = {asn: asn, name: name}
    end
  end
end
