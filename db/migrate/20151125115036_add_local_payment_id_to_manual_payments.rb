class AddLocalPaymentIdToManualPayments < ActiveRecord::Migration
  def change
    add_column :manual_payments, :local_payment_id, :string
  end
end
