class ChangeAmountStringToIntegerInFeePaymentNotification < ActiveRecord::Migration
  def up
    change_column :fee_payment_notifications, :amount, 'Integer USING CAST(amount AS Integer)'
  end

  def down  
    change_column :fee_payment_notifications, :amount,:string
  end
end
