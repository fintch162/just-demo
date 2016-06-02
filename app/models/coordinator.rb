class Coordinator < AdminUser
  validates :name, presence: true
  has_one :coordinator_api_setting
  has_many :messages
  has_many :conversations, dependent: :destroy
  has_many :coordinator_classes

 	has_attached_file :profile_picture, :styles => { :medium => "300x300>", :thumb => "100x100>" }, 
                                      :default_url => "/images/:style/missing.png"
                                      # :storage => :s3,
                                      # :bucket => 'profileImage',
                                      # :s3_credentials => { 
                                      #   :access_key_id     => 'AKIAIJKEHEKSMD5UNCPQ', 
                                      #   :secret_access_key => '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' }

	validates_attachment_content_type :profile_picture, :content_type => /\Aimage\/.*\Z/

  def coordinator?
    true
  end
end 