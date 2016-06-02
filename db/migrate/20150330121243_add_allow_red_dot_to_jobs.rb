class AddAllowRedDotToJobs < ActiveRecord::Migration
  def change
     add_column :jobs, :allow_red_dot, :boolean ,:default => "false"
  end
end
