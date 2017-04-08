class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :private_key
      t.string :public_key
      t.decimal :balance, default: 0

      t.timestamps
    end
    add_index :accounts, :name
    add_index :accounts, :private_key
    add_index :accounts, :public_key
  end
end
