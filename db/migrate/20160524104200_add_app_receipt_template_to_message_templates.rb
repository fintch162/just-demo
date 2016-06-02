class AddAppReceiptTemplateToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :app_receipt_template, :text
  end
end
