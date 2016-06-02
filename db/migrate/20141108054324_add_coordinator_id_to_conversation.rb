class AddCoordinatorIdToConversation < ActiveRecord::Migration
  def change
    add_column :conversations, :coordinator_id, :integer
  end
end
