class AddColumnToVideo < ActiveRecord::Migration
   def self.up
    add_column :videos, :student_video_processing, :boolean
  end

  def self.down
    remove_column :videos, :student_video_processing
  end
end
