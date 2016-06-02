class AddAmountAndPaymentMethodAndCustomerEmailToOnlinePayments < ActiveRecord::Migration
  def change
    add_column :online_payments, :amount, :string
    add_column :online_payments, :payment_method, :string
    add_column :online_payments, :customer_email, :string
  end
end
