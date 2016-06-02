class AddReceiptNoteToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :receipt_note, :text
  end
end
