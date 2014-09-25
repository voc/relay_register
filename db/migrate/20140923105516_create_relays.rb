class CreateRelays < ActiveRecord::Migration
  def change
    create_table :relays do |t|
      t.string :ip
      t.string :mac
      t.string :hostname
      t.string :master
      t.string :measured_bandwith
      t.text :contact
      t.text :ip_config
      t.text :disk_size
      t.text :cpu
      t.text :memory
      t.text :lspci
      t.timestamps
    end
  end
end
