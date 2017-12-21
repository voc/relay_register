class RelaysTags < ActiveRecord::Migration[4.2]
  def change
    create_table :relays_tags, id: false do |t|
      t.integer :relay_id
      t.integer :tag_id
    end
  end
end
