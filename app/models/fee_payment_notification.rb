class FeePaymentNotification < ActiveRecord::Base
  serialize :response_params
  belongs_to :fee
  scope :paid_notification, -> {where(status:'Paid').first}
  scope :paid_by_credit_card_notification, -> {find_by(status:'Paid',paid_by: "Reddot Visa/Master")}
  scope :fee_payment, ->(start_date,end_date) {where(:created_at => start_date..end_date).order("created_at DESC") }
  def payment_method
  	self.paid_by == 'Reddot Visa/Master' ? 'Credit Card' : 'eNets'
  end
end
