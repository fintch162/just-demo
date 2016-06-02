class CoordinatorClass < ActiveRecord::Base
  belongs_to :venue
  belongs_to :instructor
  belongs_to :age_group
  belongs_to :coordinator
  belongs_to :fee_type
end
