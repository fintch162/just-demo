class AddFinalFromNumberToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :final_from_number, :string
  end
end
