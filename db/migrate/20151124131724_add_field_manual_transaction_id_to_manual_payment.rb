class AddFieldManualTransactionIdToManualPayment < ActiveRecord::Migration
  def change
    add_column :manual_payments, :manual_transaction_id, :string
  end
end
