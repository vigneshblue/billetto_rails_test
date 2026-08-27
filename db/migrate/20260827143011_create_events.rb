class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.integer :event_id, null: false
      t.string :title, null: false
      t.text :description
      t.datetime :start_date
      t.string :image_url
      t.string :event_url
      t.string :country

      t.timestamps
    end

    add_index :events, :event_id, unique: true
    add_index :events, :title
  end
end
