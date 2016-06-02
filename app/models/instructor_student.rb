class InstructorStudent < ActiveRecord::Base
  belongs_to :admin_user
	has_many :instructor_student_group_classes
  has_many :group_classes, through: :instructor_student_group_classes

  has_many :instructor_student_awards, :dependent => :destroy
  has_many :awards, through: :instructor_student_awards
  has_many :award_test_payment_notifications, dependent: :destroy
  belongs_to :group

  has_many :student_group_class_histories, dependent: :destroy

  accepts_nested_attributes_for :instructor_student_awards, 
											  				:reject_if => lambda { |a| ( a[:award_id].to_i == 0) },
											          :allow_destroy => true
  has_many :student_identities, :dependent => :destroy
  has_many :student_contacts
  accepts_nested_attributes_for :student_contacts,
                                :reject_if => :all_blank,
                                :allow_destroy => true                              

  has_attached_file :profile_picture, :styles => { :medium => "300x300>", :thumb => "100x100>" }, 
                                      :default_url => "/images/:style/missing.png"
                                      # :storage => :s3,
                                      # :bucket => 'profileImage',
                                      # :s3_credentials => { 
                                      #   :access_key_id     => 'AKIAIJKEHEKSMD5UNCPQ', 
                                      #   :secret_access_key => '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' 
                                      # }

                                                                             
  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/
	has_many	:fees, :dependent => :destroy
  has_many :instructor_student_timings, :dependent => :destroy
  has_many  :photos, :dependent => :destroy
  has_one   :gallery, :dependent => :destroy
  
  before_create :create_secret_token
  has_many :transfers
  has_many :photo_tags, :dependent => :destroy

  scope :ids_by_name, ->(student_name) { where("LOWER(student_name) LIKE ?", "%#{student_name}%").pluck('id') }

  def create_secret_token
    secret_token = Array.new(5){rand(36).to_s(36)}.join
    self.secret_token = secret_token
  end 
  def get_fee_or_group_class_fee
    self.fee.present? ? self.fee : self.group_classes.first.fee
  end
  def get_pronouns
    self.gender == 'Male' ? 'he' : 'she'
  end
  def add_to_past_group_class_ids(ids)
     self.past_group_class_ids += ids
     self.past_group_class_ids = self.past_group_class_ids.uniq
  end 
  def self.unpaid_students(student_ids,monthly_detail)
    unpaid_students_ids = []
    paid_students_ids = []
    invoice_students_ids = []
    @unpaid_students = []
    @invoice_students = []
    @paid_students = []
    @students = InstructorStudent.where('id IN (?)',student_ids.split(',')).includes(:fees)
    @students.each do |student|
      if student.fees.find_by(monthly_detail:monthly_detail).try(:is_paid)
        paid_students_ids << student.id
      elsif student.fees.find_by(monthly_detail:monthly_detail).try(payment_status: 'Due')
        invoice_students_ids << student.id
      else
        unpaid_students_ids << student.id
      end
    end
    if unpaid_students_ids.count > 0
      @unpaid_students = InstructorStudent.where('id IN (?)',unpaid_students_ids)
    end
    if paid_students_ids.count > 0
      @paid_students = InstructorStudent.where('id IN (?)',paid_students_ids)
    end
    if invoice_students_ids.count > 0
      @invoice_students = InstructorStudent.where('id IN (?)',invoice_students_ids)
    end
    return [@unpaid_students,@paid_students,@invoice_students]
  end
  def self.set_bulk_invoice(student_ids,monthly_detail,due_date,group_class)
    @students = InstructorStudent.where('id IN (?)',student_ids)
    @students.each do |student|
      amount = student.fee.present? ? student.fee : group_class.fee
      fee = nil
      fee = student.fees.find_by(monthly_detail:monthly_detail)
      if fee
        fee.update(payment_status: 'Due',due_date: due_date)
      else
        student.fees.create(course_type: group_class.try(:fee_type).try(:name),amount: amount,monthly_detail: monthly_detail,
        instructor_id: student.admin_user_id,payment_status: 'Due',due_date: due_date)
      end 
    end
  end

  def chek_monthly_fee
    @next_month_fee=(Date.today() + 1.month).strftime("%Y-%m-01")
    @fee = self.fees.find_by(monthly_detail: @next_month_fee.to_date)
    @fee
  end

  def chek_current_month_fee(month)
    # @current_month_fee=Date.today().strftime("%Y-%m-01")
    @current_month_fee=month.strftime("%Y-%m-01")
    @fee = self.fees.find_by(monthly_detail: @current_month_fee.to_date , course_type: "per month")
    @fee
  end
end