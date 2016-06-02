require File.join(Rails.root, "lib", "carrier_wave", "ffmpeg")
# require File.join(Rails.root, "lib", "carrier_wave", "delayed_job") # New
 
class AssetUploader < CarrierWave::Uploader::Base
  # include CarrierWave::Delayed::Job
  # include CarrierWave::FFMPEG
 
  # Choose what kind of storage to use for this uploader:
  storage :file
 
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{Rails.root}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
 
  # Add a version, utilizing our processor
  version :bitrate_128k do
    process :resample => "128k"
  end
end