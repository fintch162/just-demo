class CreatePaymentNotifications < ActiveRecord::Migration
  def change
    create_table :payment_notifications do |t|
      t.text :params
      t.integer :online_payment_id
      t.string :status
      t.string :transaction_id
      t.string :create

      t.timestamps
    end
  end
end
