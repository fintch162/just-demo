class AddDurationToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :duration, :string
  end
end
