class JobVenue < ActiveRecord::Base
  belongs_to :job
  belongs_to :venue
end
