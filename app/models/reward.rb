class Reward < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :job
end
