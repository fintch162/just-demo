class CreateInstructorFeatures < ActiveRecord::Migration
  def change
    create_table :instructor_features do |t|
      t.references :instructor, index: true
      t.references :feature, index: true
      t.boolean :is_enabled,default: :false

      t.timestamps
    end
  end
end
