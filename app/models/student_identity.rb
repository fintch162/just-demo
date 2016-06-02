class StudentIdentity < ActiveRecord::Base
  belongs_to :instructor_student
  has_attached_file :identity_doc, :styles => { :medium => "300x300>", :thumb => "100x100>" }, 
                                      :default_url => "/images/:style/missing.png"
                                      # :storage => :s3,
                                      # :s3_credentials => {
                                      #   :bucket => 'studentIdentityDocuments',
                                      #   :access_key_id =>  'AKIAIJKEHEKSMD5UNCPQ',
                                      #   :secret_access_key => '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'
                                      # }
  validates_attachment_content_type :identity_doc, :content_type => /\Aimage\/.*\Z/                                    
end