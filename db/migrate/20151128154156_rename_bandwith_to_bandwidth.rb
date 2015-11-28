class RenameBandwithToBandwidth < ActiveRecord::Migration
  def change
    rename_column :relays, :measured_bandwith, :measured_bandwidth
    rename_table  :bandwiths, :bandwidths
  end
end
