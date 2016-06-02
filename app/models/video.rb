class Video < ActiveRecord::Base
  belongs_to :gallery
  belongs_to :instructor_student

  mount_uploader :video_file, VideoUploader do
    def url(format = nil)
      uploaded_path = encode_path(file.path.sub(File.expand_path(root), ''))
      return uploaded_path if format.nil?
      files = Dir.entries(File.dirname(file.path))
      files.each do |f|
        next unless File.extname(f) == '.' + format.to_s
        return File.dirname(uploaded_path) + '/' + f
      end
    end
  end
  # mount_uploader :video_file, VideoUploader
  
  ## VALIDATIONS
  validates :video_file, presence: true
  validates_integrity_of :video_file
  validates_processing_of :video_file
    # has_attached_file :student_video,   styles: lambda { |a| a.instance.is_image? ? {:small => "x200>", :medium => "x300>", :large => "x400>"}  : {:thumb => { :geometry => "100x100#", :format => 'jpg', :time => 10}, :medium => { :geometry => "300x300#", :format => 'jpg', :time => 10}}},
    #       :processors => lambda { |a| a.is_video? ? [ :ffmpeg ] : [ :thumbnail ] }
    # validates_attachment_content_type :video, content_type: /\Avideo\/.*\Z/  

    # :styles => {
    # :medium => { :geometry => "640x480", :format => 'mp4' },
    # :thumb => { :geometry => "100x100#", :format => 'jpg', :time => 10 }
    # }, :processors => [:ffmpeg]

  # validates_attachment_presence :student_video
  # validates_attachment_content_type :student_video, :content_type => ['application/x-shockwave-flash', 'application/x-shockwave-flash', 'application/flv', 'video/x-flv', 'application/mp4']
  # validates_attachment_size :student_video, :less_than => 250.megabytes
end
