class MobileDevice < ActiveRecord::Base
  validates :device_registration_id, uniqueness: true
end
