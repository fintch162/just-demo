class CreateFeePaymentNotifications < ActiveRecord::Migration
  def change
    create_table :fee_payment_notifications do |t|
      t.text :response_params
      t.string :status
      t.string :transaction_id
      t.string :paid_by
      t.string :amount
      t.references :fee, index: true
      t.string :merchant_reference

      t.timestamps
    end
  end
end
