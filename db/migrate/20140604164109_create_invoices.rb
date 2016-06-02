class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :freshbooks_invoice_id
      t.integer :invoice_number

      t.timestamps
    end
  end
end
