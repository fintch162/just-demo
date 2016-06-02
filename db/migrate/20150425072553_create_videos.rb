class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :gallery_id
      t.integer :instructor_student_id	

      t.timestamps
    end
  end
end
