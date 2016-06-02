class Instructor < AdminUser
  # require 'telerivet-ruby-client/telerivet'

  require 'telerivet'
  validates :mobile, :name, presence: true
  #before_save :create_telerivet_contact
  before_save :trim_space_from_string
  has_attached_file :profile_picture, :styles => { :medium => "300x300>", :thumb => "100x100>" }, 
                                      :default_url => "/images/:style/missing.png"
                                      # :storage => :s3,
                                      # :bucket => 'profileImage',
                                      # :s3_credentials => { 
                                      #   :access_key_id     => 'AKIAIJKEHEKSMD5UNCPQ', 
                                      #   :secret_access_key => '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' }

  has_attached_file :company_logo, :styles => { :medium => "300x300>", :thumb => "100x100>" }, 
                                      :default_url => "/images/:style/missing-logo.gif"
                                      # :storage => :s3,
                                      # :bucket => 'profileImage',
                                      # :s3_credentials => { 
                                      #   :access_key_id     => 'AKIAIJKEHEKSMD5UNCPQ', 
                                      #   :secret_access_key => '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' }


  validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :company_logo, :content_type => /\Aimage\/.*\Z/

  has_many :group_classes
  has_many :instructor_messages, dependent: :destroy
  has_many :instructor_conversations, dependent: :destroy
  has_many :instructor_student_photos, dependent: :destroy
  has_many :jobs
  has_many :rewards
  has_many :fees
  has_many :fee_payment_notifications, through: :fees
  has_many :award_test_payment_notifications, through: :instructor_students
  has_one :instructor_company_detail
  has_many :coordinator_classes
  has_many :instructor_identities
  has_many :hide_show_columns
  has_many :more_or_less_months
  has_many :photo_tags

  has_many :transfers, :foreign_key => "transfer_to", :class_name => "Transfer"
  has_many :instructor_features, dependent: :destroy
  has_many :features,through: :instructor_features

  accepts_nested_attributes_for :instructor_identities,
                                :reject_if => :all_blank,
                                :allow_destroy => true
  def instructor?
    true
  end

  def enable_feature
    if self.instructor_features.where(is_enabled: true).count > 0
      return true
    else
      return false
    end
  end
  def reddot_enable
    if self.instructor_features.where(is_enabled: true).pluck('feature_id').include?(Feature.reddot_card_id)
      return true
    else
      return false
    end
  end
  def eNets_enable
    if self.instructor_features.where(is_enabled: true).pluck('feature_id').include?(Feature.eNets_id)
      return true
    else
      return false
    end
  end

  def create_telerivet_contact
    api_key = ApiSetting.first.telerivet_api_key
    project_id = ApiSetting.first.telerivet_project_id

    tr = Telerivet::API.new(api_key)
    project = tr.get_project_by_id(project_id)

    contact = project.get_or_create_contact({
      'name' => self.name, 
      'phone_number' => self.mobile, 
    })
    self.tr_contact_id = contact.id
  end
  def instructor_name_and_mobile
    "#{name} - #{note} (#{mobile})"
  end

  def trim_space_from_string
    self.note = self.note.strip unless self.note.nil?
    self.name = self.name.strip unless self.name.nil?
    self.short_name = self.short_name.strip unless self.short_name.nil?
    self.mobile = self.mobile.strip unless self.mobile.nil?
  end

  def active_student_ids
    instructor_students = self.instructor_students
    active_students = []
    instructor_students.each do |instructor_student|
      if instructor_student.group_classes.count != 0 
        active_students << instructor_student.id
      end
    end
    return active_students
  end

  scope :find_inst_by_name, lambda { |value| where("lower(name) = ?", value.downcase).first }

  def self.periodically_send_student_detail
    where(daily_backup_on: true).each do |instructor|
      @fee_type = FeeType.find_by(name: 'per month')
      @group_classes = instructor.group_classes.where(fee_type_id: @fee_type.id).order('day asc,time asc').where(is_deleted: false)
      days_arry = []
      all_days_arr = []
      @group_classes.each do |group_class|
        if group_class.day.to_i == 0
          days_arry << group_class
        else
           all_days_arr << group_class
        end
      end
      @group_classes = all_days_arr + days_arry
      @day = Job::DAY_NAMES
      @m = 11
      current_year_start_date = Date.today.beginning_of_year
      @month_array = []
      (0..@m).each do |m|
        @month_array << (current_year_start_date + m.month)
      end

      DailyBackupMail.student_info_to_instructor(instructor, @group_classes, @month_array).deliver
    end
  end
end