class AddInvoiceTimeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :invoice_time, :datetime
  end
end
