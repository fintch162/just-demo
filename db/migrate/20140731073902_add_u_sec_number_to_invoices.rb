class AddUSecNumberToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :u_sec_number, :string
    Invoice.reset_column_information
    Invoice.all.each do |inv|
      inv.update_attributes!(:u_sec_number => Array.new(5){rand(36).to_s(36)}.join)
    end
  end
end
