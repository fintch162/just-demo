class TermsAndCondition < ActiveRecord::Base
	has_and_belongs_to_many :jobs, :join_table => :job_terms_and_conditions
end
