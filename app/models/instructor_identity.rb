class InstructorIdentity < ActiveRecord::Base
  belongs_to :identity_card
  belongs_to :instructor

  has_attached_file :identity_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, 
                                      :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :identity_image, :content_type => /\Aimage\/.*\Z/
                                      
end
