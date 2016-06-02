class AddVideoFileToVideo < ActiveRecord::Migration
   def change
    add_column :videos, :video_file, :string
   end
end
