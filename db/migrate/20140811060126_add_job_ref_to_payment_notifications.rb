class AddJobRefToPaymentNotifications < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :job_ref, :integer
  end
end
