class AddPayTimeToPaymentNotification < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :pay_time, :time
  end
end
