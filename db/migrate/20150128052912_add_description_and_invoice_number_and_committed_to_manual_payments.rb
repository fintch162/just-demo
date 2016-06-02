class AddDescriptionAndInvoiceNumberAndCommittedToManualPayments < ActiveRecord::Migration
  def change
    add_column :manual_payments, :description, :text
    add_column :manual_payments, :invoice_number, :string
    add_column :manual_payments, :committed, :boolean
  end
end
