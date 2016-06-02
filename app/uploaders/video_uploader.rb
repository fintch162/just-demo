class VideoUploader < CarrierWave::Uploader::Base
  include CarrierWave::FFMPEG

 storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
   
  def extension_white_list
    %w(mp4 mv4 webm mov flv wmv avi mpeg2 quicktime)
  end 

  version :webm do
    process :encode_video => [:webm]
    # def full_filename(for_file)
    #   "#{File.basename(for_file, File.extname(for_file))}.webm"
    # end
  end
  
  version :mp4 do
    process :encode_video => [:mp4]
    # def full_filename(for_file)
    #   "#{File.basename(for_file, File.extname(for_file))}.mp4"
    # end
  end

  version :mov do
    process :encode_video => [:mp4]
    # def full_filename(for_file)
    #   "#{File.basename(for_file, File.extname(for_file))}.mp4"
    # end
  end
  

  # version :ogv do
  #   process :encode_video => [:ogv]
  #   # def full_filename(for_file)
  #   #   "#{File.basename(for_file, File.extname(for_file))}.ogv"
  #   # end
  # end
end