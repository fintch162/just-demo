class InstructorFeature < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :feature
end
