class ChangeDatatypeOfSsaPaymentProcessFeeFromStringToInteger < ActiveRecord::Migration
  def up
    change_column :ssa_payment_process_fees, :transaction_fee,'Float USING CAST(transaction_fee AS Float)'
    change_column :ssa_payment_process_fees, :processing_fee,'Float USING CAST(processing_fee AS Float)'
  end

  def down
    change_column :ssa_payment_process_fees, :transaction_fee, :string
    change_column :ssa_payment_process_fees, :processing_fee, :string
  end
end
