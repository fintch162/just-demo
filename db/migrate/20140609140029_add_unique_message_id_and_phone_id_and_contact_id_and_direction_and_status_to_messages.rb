class AddUniqueMessageIdAndPhoneIdAndContactIdAndDirectionAndStatusToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :unique_message_id, :string
    add_column :messages, :phone_id, :string
    add_column :messages, :contact_id, :string
    add_column :messages, :direction, :string
    add_column :messages, :status, :string
  end
end
