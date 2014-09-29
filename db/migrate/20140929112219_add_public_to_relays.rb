class AddPublicToRelays < ActiveRecord::Migration
  def change
    add_column :relays, :public, :boolean
  end
end
