class CreateCharges < ActiveRecord::Migration[5.0]
  def change
    create_table :charges do |t|
      t.references :account, foreign_key: true
      t.references :card, foreign_key: true
      t.decimal :amount
      t.datetime :charge_timestamp

      t.timestamps
    end
  end
end
