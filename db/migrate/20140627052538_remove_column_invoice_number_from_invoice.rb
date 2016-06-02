class RemoveColumnInvoiceNumberFromInvoice < ActiveRecord::Migration
  def change
  	remove_column :invoices, :invoice_number
  end
end
