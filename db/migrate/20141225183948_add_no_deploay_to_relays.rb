class AddNoDeploayToRelays < ActiveRecord::Migration[4.2]
  def change
    add_column :relays, :cm_deploy, :boolean, default: true
  end
end
