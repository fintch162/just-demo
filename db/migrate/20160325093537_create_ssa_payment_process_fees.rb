class CreateSsaPaymentProcessFees < ActiveRecord::Migration
  def change
    create_table :ssa_payment_process_fees do |t|
      t.string :payment_name
      t.date :from_date
      t.string :transaction_fee
      t.string :processing_fee
      t.timestamps
    end
  end
end
