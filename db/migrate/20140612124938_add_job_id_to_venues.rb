class AddJobIdToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :job_id, :integer
  end
end
