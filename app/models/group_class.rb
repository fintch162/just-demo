class GroupClass < ActiveRecord::Base
  extend Filterable

  belongs_to :venue
  belongs_to :instructor
  belongs_to :age_group
  # belongs_to :class_type
  belongs_to :level
  belongs_to :fee_type
  belongs_to :admin_user
  has_many :instructor_student_group_classes
  has_many :instructor_students, through: :instructor_student_group_classes
  has_many :groups, dependent: :destroy
  has_many :instructor_messages, dependent: :destroy
  has_many :student_group_class_histories, dependent: :destroy
  scope :preloaded, ->{ includes(:instructor, :venue, :level, :age_group) }
  scope :is_active, ->{ where("is_deleted = false") }

  has_many :student_attendances
  attr_reader :fromInstAjax

  # validates_length_of :duration, :maximum => 2

  def time_formatted
    time.strftime("%I.%M %p") if time
  end
  def formatted_time
    time.strftime("%I:%M%P") if time
  end

  def heading
    Date::DAYNAMES[self.day] + ' ' + self.time.strftime("%I:%M %p")
  end

  def custom_heading
    if self.time.present?
      Date::ABBR_DAYNAMES[self.day] + ' ' +self.time.strftime("%I:%M %p")
    else
      Date::ABBR_DAYNAMES[self.day]
    end
  end

  def short_heading
    if self.time.present?
      Date::ABBR_DAYNAMES[self.day] + ' ' +self.formatted_time
    else
      Date::ABBR_DAYNAMES[self.day]
    end
  end

  def full_time
    self.time.strftime("%I:%M %p") + " - " + (self.time + self.duration*60).strftime("%I:%M %p")
  end

  def full_time_heading
    self.heading + " - " + (self.time + self.duration*60).strftime("%I:%M %p")
  end

#  FeeType.all.each do |fee_type|
#    if fee_type.name.downcase == "per month"
#      @feeId = fee_type.id
#    end
#  end
end
