class RenameJobIdFromPaymentNotification < ActiveRecord::Migration
  def change
    rename_column :payment_notifications, :job_id, :invoice_id
  end
end
