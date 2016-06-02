class AddColumnBankIdToPaymentNotification < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :bank_id, :integer
  end
end
