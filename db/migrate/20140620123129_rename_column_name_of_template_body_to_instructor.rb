class RenameColumnNameOfTemplateBodyToInstructor < ActiveRecord::Migration
  def change
    rename_column :message_templates, :template_body, :instructor_template_body
  end
end
