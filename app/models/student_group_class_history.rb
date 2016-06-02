class StudentGroupClassHistory < ActiveRecord::Base
  belongs_to :instructor_student
  belongs_to :group_class
end
