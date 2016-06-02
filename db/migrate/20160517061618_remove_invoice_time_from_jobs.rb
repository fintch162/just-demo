class RemoveInvoiceTimeFromJobs < ActiveRecord::Migration
  def change
    remove_column :jobs, :invoice_time, :datetime
  end
end
