class CreatePhotoTags < ActiveRecord::Migration
  def change
    create_table :photo_tags do |t|
      t.references :instructor_student, index: true
      t.integer :phototaggable_id
      t.string :phototaggable_type
      t.string :student_name
      t.references :instructor, index: true

      t.timestamps
    end
  end
end
