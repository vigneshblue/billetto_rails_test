class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :clerk_user_id, null: false

      t.timestamps
    end

    add_index :users, :clerk_user_id, unique: true
  end
end
