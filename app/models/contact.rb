class Contact < ActiveRecord::Base
  def self.create_contact(phone_no, contact_id)
    self.create(:phone_number => phone_no, :contact_id => contact_id)
  end
end
