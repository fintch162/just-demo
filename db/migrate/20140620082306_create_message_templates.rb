class CreateMessageTemplates < ActiveRecord::Migration
  def change
    create_table :message_templates do |t|
      t.string :job_status
      t.boolean :has_instructor
      t.boolean :has_customer
      t.text :template_body

      t.timestamps
    end
  end
end
