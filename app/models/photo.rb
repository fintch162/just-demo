class Photo < ActiveRecord::Base
	belongs_to :gallery
  	has_many :photo_tags, :as => :phototaggable, dependent: :destroy
	belongs_to :instructor_student

	has_attached_file :student_photo, :styles => {  :original =>"100x100%", :medium => "300x300>" ,:small => "200x200#" },
	                  :url  => "/system/photos/:id/:style/:basename.:extension",
	                  :path => ":rails_root/public/system/photos/:id/:style/:basename.:extension"

	validates_attachment_content_type :student_photo, :content_type => %w(image/jpeg image/jpg image/png image/gif image/tiff)

end