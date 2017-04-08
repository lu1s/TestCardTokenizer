class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.string :card_number
      t.integer :expiration_month
      t.integer :expiration_year
      t.string :secure_code
      t.string :card_token
      t.datetime :token_timestamp

      t.timestamps
    end
    add_index :cards, :card_token
  end
end
