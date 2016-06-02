class AddPrintLeadNameToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :print_lead_name, :string
  end
end
