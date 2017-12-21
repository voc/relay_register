class AddPublicToRelays < ActiveRecord::Migration[4.2]
  def change
    add_column :relays, :public, :boolean
  end
end
