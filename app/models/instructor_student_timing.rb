class InstructorStudentTiming < ActiveRecord::Base
  belongs_to :instructor_student
  belongs_to :timing
end
