class AddNoDeploayToRelays < ActiveRecord::Migration
  def change
    add_column :relays, :cm_deploy, :boolean, default: true
  end
end
