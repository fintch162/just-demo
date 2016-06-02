class AddEnetsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :enets, :boolean,:default => "false"
  end
end
