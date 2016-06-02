class AddAmountToPaymentNotifications < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :amount, :string
  end
end
