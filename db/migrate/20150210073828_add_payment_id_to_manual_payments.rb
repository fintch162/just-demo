class AddPaymentIdToManualPayments < ActiveRecord::Migration
  def change
    add_column :manual_payments, :payment_id, :string
  end
end
