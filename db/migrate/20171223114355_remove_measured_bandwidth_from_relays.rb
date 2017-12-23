class RemoveMeasuredBandwidthFromRelays < ActiveRecord::Migration[5.1]
  def change
    remove_column :relays, :measured_bandwidth, :string
    drop_table :bandwidths
  end
end
