class FeeType < ActiveRecord::Base
	has_many :group_classes
	has_many :jobs
	has_many :coordinator_classes
	scope :per_month_id, -> { find_by_name("per month").id }
end
