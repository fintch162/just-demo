class ChangeAmountStringToFloatInAwardTestPaymentNotification < ActiveRecord::Migration
  def up
    change_column :award_test_payment_notifications, :amount, 'Float USING CAST(amount AS Float)'
  end

  def down  
    change_column :award_test_payment_notifications, :amount,:string
  end
end
