class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :invoice_id
      t.integer :freshbooks_payment_id
      t.integer :amount
      t.integer :expense
      t.text :note
      t.string  :method
      t.string :mode

      t.timestamps
    end
  end
end
