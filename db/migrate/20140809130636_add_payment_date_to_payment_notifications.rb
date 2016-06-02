class AddPaymentDateToPaymentNotifications < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :payment_date, :date
  end
end
