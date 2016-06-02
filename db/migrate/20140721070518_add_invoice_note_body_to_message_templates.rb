class AddInvoiceNoteBodyToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :invoice_note_body, :text
  end
end
