class Transfer < ActiveRecord::Base
	belongs_to :instructor
	belongs_to :instructor_student
end
