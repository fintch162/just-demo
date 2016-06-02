class CreateInstructorJobApplications < ActiveRecord::Migration
  def change
    create_table :instructor_job_applications do |t|
      t.integer :instructor_id
      t.integer :job_id
      t.text :description
      t.boolean :applied ,default: :false

      t.timestamps
    end
  end
end
