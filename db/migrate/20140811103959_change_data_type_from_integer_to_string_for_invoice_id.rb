class ChangeDataTypeFromIntegerToStringForInvoiceId < ActiveRecord::Migration
  def change
    change_column :payment_notifications, :invoice_id, :string
  end
end
