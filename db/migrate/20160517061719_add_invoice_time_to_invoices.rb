class AddInvoiceTimeToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :invoice_time, :datetime
  end
end
