class AddBulkSmsIdToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :bulk_sms_id, :string
  end
end
