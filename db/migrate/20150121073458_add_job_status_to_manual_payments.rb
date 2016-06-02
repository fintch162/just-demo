class AddJobStatusToManualPayments < ActiveRecord::Migration
  def change
    add_column :manual_payments, :job_status, :string
  end
end
