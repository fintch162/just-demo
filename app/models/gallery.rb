class Gallery < ActiveRecord::Base
	 belongs_to :instructor_student
	 has_many :photos
	 accepts_nested_attributes_for :photos
	 has_many :videos
	 # accepts_nested_attributes_for :videos
end
