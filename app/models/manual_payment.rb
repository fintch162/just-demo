class ManualPayment < ActiveRecord::Base
	acts_as_list
	belongs_to :job
end
