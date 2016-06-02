class RemoveJobIdFromVenue < ActiveRecord::Migration
  def change
    remove_column :venues, :job_id
  end
end
