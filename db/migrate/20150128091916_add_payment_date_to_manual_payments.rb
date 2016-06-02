class AddPaymentDateToManualPayments < ActiveRecord::Migration
  def change
    add_column :manual_payments, :payment_date, :date
  end
end
