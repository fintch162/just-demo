class AddInvoicePaBodyToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :invoice_pa_body, :text
  end
end
