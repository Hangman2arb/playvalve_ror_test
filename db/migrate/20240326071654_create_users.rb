class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :idfa
      t.integer :ban_status, default: 0

      t.timestamps
    end
    add_index :users, :idfa
  end
end
