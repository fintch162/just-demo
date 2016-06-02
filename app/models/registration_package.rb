class RegistrationPackage < ActiveRecord::Base
	belongs_to :age_group
	has_many   :jobs 

	validates :no_of_student ,:price,:age_group_id, presence: true
end
