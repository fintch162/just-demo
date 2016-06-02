class RenameCreateToPaidByToPaymentNotifications < ActiveRecord::Migration
  def change
    rename_column :payment_notifications, :create, :paid_by
  end
end
