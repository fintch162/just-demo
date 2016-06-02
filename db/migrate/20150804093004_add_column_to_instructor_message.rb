class AddColumnToInstructorMessage < ActiveRecord::Migration
  def change
    add_column :instructor_messages, :bulk_sms_id, :string
  end
end
