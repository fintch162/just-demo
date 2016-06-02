class ChangeDataTypeIntegerToFloatInFeePaymentNotification < ActiveRecord::Migration
  def change
  	change_column :fee_payment_notifications, :amount, 'Float USING CAST(amount AS Float)'
  end
end
