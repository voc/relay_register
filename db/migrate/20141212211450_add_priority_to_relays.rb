class AddPriorityToRelays < ActiveRecord::Migration[4.2]
  def change
    add_column :relays, :dns_priority, :integer, default: 0
  end
end
