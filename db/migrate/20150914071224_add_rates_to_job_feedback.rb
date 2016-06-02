class AddRatesToJobFeedback < ActiveRecord::Migration
  def change
    add_column :job_feedbacks, :rates, :float
  end
end
