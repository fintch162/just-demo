class MessageFieldsCorrections < ActiveRecord::Migration
  def change
    rename_column :messages, :to, :to_nubmer
    rename_column :messages, :message_description, :content
    
    add_column :messages, :project_id, :string
    add_column :messages, :message_type, :string
    add_column :messages, :source, :string
    add_column :messages, :time_created, :integer
    add_column :messages, :from_number, :integer
    add_column :messages, :starred, :integer

  end
end