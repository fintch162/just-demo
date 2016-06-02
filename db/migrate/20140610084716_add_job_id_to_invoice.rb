class AddJobIdToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :job_id, :integer
    change_column :jobs, :preferred_time, :text
  end
end
