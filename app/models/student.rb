class Student < ActiveRecord::Base
  belongs_to :job
  GENDER = [ "M", "F" ]
end
