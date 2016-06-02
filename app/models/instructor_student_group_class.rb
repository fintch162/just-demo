class InstructorStudentGroupClass < ActiveRecord::Base
	# has_one    :instructor_student
 #  has_one    :group_class
  belongs_to :group_class
  belongs_to :instructor_student
end
