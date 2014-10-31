class CreateBandwiths < ActiveRecord::Migration
  def change
    create_table :bandwiths do |t|
      t.belongs_to  :relay
      t.string      :destination
      t.text        :iperf
      t.boolean     :at_the_same_time, default: false
      t.boolean     :is_deleted, default: false

      t.timestamps
    end
  end
end
