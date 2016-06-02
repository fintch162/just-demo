class ChangeAmountStringToFloatInPaymentNotification < ActiveRecord::Migration
  def up
		a = PaymentNotification.pluck(:id,:amount)

    PaymentNotification.update_all(:amount => nil)
	  change_column :payment_notifications, :amount, 'float USING CAST(amount AS float)'

	  a.each do |a|
	  	if !a[1].nil?
	  		PaymentNotification.find(a[0]).update_attributes(amount: a[1].to_f)
	  	else
	  		PaymentNotification.find(a[0]).update_attributes(amount: 0)
	  	end
	  end
  end

  def down
  	a = PaymentNotification.pluck(:id,:amount)
  	PaymentNotification.update_all(:amount=> nil)
  	change_column :payment_notifications, :amount,:string
  	a.each do |a|
	  	if !a[1].nil?
	  		PaymentNotification.find(a[0]).update_attributes(amount: a[1].to_s)
	  	else
	  		PaymentNotification.find(a[0]).update_attributes(amount: "")
	  	end
	  end
  end
end