class AddRequestFullPaymentAndAllowPaypalToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :request_full_payment, :boolean, :default => "false"
    add_column :jobs, :allow_paypal, :boolean, :default => "false"
  end
end
