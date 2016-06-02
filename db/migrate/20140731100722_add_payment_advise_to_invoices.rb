class AddPaymentAdviseToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :payment_advise, :text
  end
end
