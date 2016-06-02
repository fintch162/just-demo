class InstructorStudentPhoto < ActiveRecord::Base
  belongs_to :instructor
  has_many :photo_tags, :as => :phototaggable, dependent: :destroy
  has_attached_file :photo, :styles => {  :original =>"100x100%", :medium => "300x300>" ,:small => "200x200#" },
	                  :url  => "/system/photos/:id/:style/:basename.:extension",
	                  :path => ":rails_root/public/system/photos/:id/:style/:basename.:extension"

	validates_attachment_content_type :photo, :content_type => %w(image/jpeg image/jpg image/png image/gif image/tiff)
end
