class AddGroupClassIdAndAppliedDateToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :group_class_id, :integer
    add_column :jobs, :applied_date, :datetime
  end
end
