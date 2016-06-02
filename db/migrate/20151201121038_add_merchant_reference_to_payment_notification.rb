class AddMerchantReferenceToPaymentNotification < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :merchant_reference, :string
  end
end
