class AddIsPaymentAddedToPaymentNotifications < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :is_payment_added, :boolean
  end
end
