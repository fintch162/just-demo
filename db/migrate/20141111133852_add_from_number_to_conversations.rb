class AddFromNumberToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :from_number, :string
  end
end
