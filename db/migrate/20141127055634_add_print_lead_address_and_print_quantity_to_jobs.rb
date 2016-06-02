class AddPrintLeadAddressAndPrintQuantityToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :print_lead_address, :string
    add_column :jobs, :print_quantity, :string
  end
end
