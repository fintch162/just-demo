class RemoveJobRefFromJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :job_ref
    remove_column :jobs, :lead_condo_name
  end
end
