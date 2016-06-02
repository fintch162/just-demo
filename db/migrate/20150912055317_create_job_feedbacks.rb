class CreateJobFeedbacks < ActiveRecord::Migration
  def change
    create_table :job_feedbacks do |t|
      t.text :reasons
      t.text :other_feedback
      t.references :job, index: true

      t.timestamps
    end
  end
end
