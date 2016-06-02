class IdentityCard < ActiveRecord::Base
  has_many :instructor_identities
end
