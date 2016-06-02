class PaymentNotification < ActiveRecord::Base
  serialize :params
  belongs_to :invoice
  scope :payment, ->(start_date,end_date) {where(:created_at => start_date..end_date).order("created_at DESC") }
end
