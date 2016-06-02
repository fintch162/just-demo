class SsaPaymentProcessFee < ActiveRecord::Base

  def self.check_data
  	self.count > 0 ? true : false
  end

  def self.check_payment_name(paid_by,date)
  	if paid_by == "Reddot Visa/Master"
  		paid_by="RedDot V/M"
  	elsif paid_by == "Reddot eNets"
  		paid_by="ENETS"
  	end
  	@payment_name = self.where(payment_name: paid_by).order("from_date desc")
  	if @payment_name.count > 0
	  	@payment_name.each do |check_date|
	  		puts"----model---#{check_date.from_date <= date.to_date }-------------------"
	  		if check_date.from_date <= date.to_date 
	  			return check_date
	  			break
	  		else
	  			next
	  		end
	  	end
	  end
  end

end
