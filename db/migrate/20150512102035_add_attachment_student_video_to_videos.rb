class AddAttachmentStudentVideoToVideos < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.attachment :student_video
    end
  end

  def self.down
    remove_attachment :videos, :student_video
  end
end
