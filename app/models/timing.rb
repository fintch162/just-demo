class Timing < ActiveRecord::Base
	has_many :instructor_student_timing, :dependent => :destroy

	def custom_name
		self.short_name.present? ? self.short_name : self.title
	end
end
