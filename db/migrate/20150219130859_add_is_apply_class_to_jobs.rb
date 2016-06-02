class AddIsApplyClassToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :is_apply_class, :boolean
  end
end
