class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.belongs_to  :topic,       index: true
      t.string      :name,        null: false
      t.integer     :position,    null: true
      t.integer     :items_count, null: false, default: 0
      t.timestamps
    end
  end
end
