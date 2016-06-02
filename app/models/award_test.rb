class AwardTest < ActiveRecord::Base
  acts_as_list
  belongs_to :admin_user
  belongs_to :award
  belongs_to :venue
  has_many :instructor_student_awards , :dependent => :destroy
  has_many :instructor_messages, dependent: :destroy
  has_many :award_test_payment_notifications, dependent: :destroy

  scope :past_award_tests, -> { where("test_date  < ?",Date.today.strftime("%e %b %Y")) }
 	scope :comming_award_tests, -> { where("test_date  >= ?",Date.today.strftime("%e %b %Y")) }
end
