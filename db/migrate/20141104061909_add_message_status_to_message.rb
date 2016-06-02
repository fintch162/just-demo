class AddMessageStatusToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :message_status, :string, default: "Read"
  end
end
