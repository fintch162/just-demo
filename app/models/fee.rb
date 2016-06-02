class Fee < ActiveRecord::Base
  belongs_to :instructor_student
  belongs_to :instructor
  has_many :fee_payment_notifications, dependent: :destroy
  scope :this_months_group_class_per_month_fee, lambda { where("monthly_detail >= ? AND monthly_detail <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month).where(:course_type.downcase => 'per month') }
  scope :this_months_group_class_per_month_fee_progress, lambda { where(:course_type.downcase => 'per month').group("DATE_TRUNC('month', monthly_detail)").sum(:amount) }
  def payment_option_heading
  	self.is_paid ? 'Receipt' : 'Invoice'
  end

  # Checking online and manullay paid fees
  def is_paid
  	self.payment_status == 'Paid' || !self.fee_payment_notifications.where(status:'Paid').first.blank? ? true : false
  end
  def is_paid_include_past
    self.payment_status == 'Paid' || !self.fee_payment_notifications.where(status:'Paid').first.blank? || (self.payment_status.nil? && self.payment_mode.nil? && self.payment_date.present?) ? true : false
  end
  def is_paid_by_credit_card
  	self.fee_payment_notifications.find_by(status:'Paid').blank? ? false : true
  end

  def is_fee_not_paid
    self.fee_payment_notifications.where(status: 'Paid')
    return fee_payment_notifications
  end

  def is_fee_paid
    self.fee_payment_notifications.find_by(status:'Paid')
  end
  def get_payment_date
  	if self.payment_date.present? 
  		self.payment_date
  	else
  		if self.is_paid_by_credit_card
  		self.is_paid_by_credit_card ? self.fee_payment_notifications.find_by(status:'Paid').created_at : nil
  		end
  	end
  end
  def get_payment_date_paid_any_payment_mode
  	if self.payment_date.present? 
  		self.payment_date
  	else
  		self.fee_payment_notifications.find_by(status:'Paid') ? self.fee_payment_notifications.find_by(status:'Paid').created_at : nil
  	end
  end

  def has_rights?(instructor)
    self.instructor.nil? ? true : self.instructor == instructor ? true : false
  end
end
