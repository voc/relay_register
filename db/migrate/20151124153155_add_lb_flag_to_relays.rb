class AddLbFlagToRelays < ActiveRecord::Migration
  def change
    add_column :relays, :lb, :boolean, default: false
  end
end
