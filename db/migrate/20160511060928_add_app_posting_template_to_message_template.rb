class AddAppPostingTemplateToMessageTemplate < ActiveRecord::Migration
  def change
    add_column :message_templates, :app_posting_template, :text
  end
end
