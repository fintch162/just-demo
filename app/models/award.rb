class Award < ActiveRecord::Base
  acts_as_list

  has_many :award_tests , :dependent => :destroy
  has_many :instructor_student_awards, :dependent => :destroy
  has_many :instructor_students, through: :instructor_student_awards

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, 
                                      :default_url => "/images/:style/missing.png"
                                      # :storage => :s3,
                                      # :bucket => 'profileImage',
                                      # :s3_credentials => { :access_key_id => 'AKIAIJKEHEKSMD5UNCPQ', 
                                      # :secret_access_key => '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' }
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def customize_name
    self.short_name.present? ? self.short_name : self.name
  end

end
