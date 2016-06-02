class AddCustomerTemplateBodyToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :customer_template_body, :text
  end
end
