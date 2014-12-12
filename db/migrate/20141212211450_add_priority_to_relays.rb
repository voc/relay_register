class AddPriorityToRelays < ActiveRecord::Migration
  def change
    add_column :relays, :dns_priority, :integer, default: 0
  end
end
