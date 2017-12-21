class AddLbFlagToRelays < ActiveRecord::Migration[4.2]
  def change
    add_column :relays, :lb, :boolean, default: false
  end
end
