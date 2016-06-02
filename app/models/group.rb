class Group < ActiveRecord::Base
  belongs_to :group_class
  has_many :instructor_students
end
