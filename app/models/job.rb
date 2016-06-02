class Job < ActiveRecord::Base
  extend Filterable
  
  before_create :default_job_status#, :create_lead_info
  belongs_to :instructor
  belongs_to :registration_package
  belongs_to :fee_type

  has_many :instructor_job_applications
  # belongs_to :venue
  has_many :job_venues
  has_many :venues, :through => :job_venues, :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  # has_many :job_public_pools
  # has_many :public_pools, :through => :job_public_pools
  has_many :students
  has_many :online_payments
  has_many :preferred_days
  has_one  :reward
  has_many :manual_payments
  has_many :job_feedback, :dependent => :destroy

  has_and_belongs_to_many :terms_and_conditions, :join_table => :job_terms_and_conditions
  
  accepts_nested_attributes_for :preferred_days, :allow_destroy => true
  # before_save :time_p_str
  accepts_nested_attributes_for :students, :allow_destroy => true
  JOB_STATUS = ["New", "Post", "Suggest", "Invoice", "Receipt"]
  CLASS_TYPE = ["Group", "Private"]
  DAY_NAMES = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  DAY_ARRAY = ["Sunday","Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
 
  def default_job_status
    if self.job_status.blank? || self.job_status == "New"
      self.job_status = "New"
    end
  end

  def to_param
    "#{id}".parameterize
  end

  def is_enable_payment_mode
    if self.allow_paypal? || self.allow_xfers? || self.bank_transfer  || self.allow_red_dot? || self.enets?
      return true
    else
      return false
    end
  end

  # def time_p_str
  #   trim_str = self.preferred_time.gsub(/\r\n/, "**%.%**")
  #   self.preferred_time = trim_str
  #   puts "................\n #{self.preferred_time} \n.................."
  # end

  # def create_lead_info
  #   arr = Array.new
  #   arr << ["<b>Starting Date :</b>" + " " + self.lead_starting_on.strftime("%y-%m-%d"), "<b>Day & Time :</b>" + " " + self.lead_day_time, "<b>Note :</b>" + " " + self.lead_info]
  #   arrstr = arr.join(",")
  #   self.lead_info = arrstr
  # end
end