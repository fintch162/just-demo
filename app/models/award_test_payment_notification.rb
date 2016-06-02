class AwardTestPaymentNotification < ActiveRecord::Base
  serialize :response_params
  belongs_to :award_test
  belongs_to :instructor_student
  scope :award_test_payment, -> (start_date,end_date) {where(:created_at => start_date..end_date).order("created_at DESC") }
  
  def self.check_paid_or_not(award_test,student)
  	AwardTestPaymentNotification.find_by(award_test_id: award_test,instructor_student_id: student,status: 'Paid') ? true : false
  end

  def self.find_paid_notification(award_test,student)
  	AwardTestPaymentNotification.find_by(award_test_id: award_test,instructor_student_id: student,status: 'Paid')
  end

  def payment_option_heading
  	self.status == 'Paid' ? 'Receipt' : 'Invoice'
  end

  def payment_method
  	if self.paid_by == 'Reddot Visa/Master' 
      return 'Credit Card' 
    elsif self.paid_by == 'Cash'
      return 'Cash'
    else 
      return 'eNets'
    end
  end

end
