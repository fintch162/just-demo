class RemoveOnlinePaymentIdFromPaymentNotifications < ActiveRecord::Migration
  def change
    remove_column :payment_notifications, :online_payment_id
    add_column :payment_notifications, :job_id, :integer
  end
end
