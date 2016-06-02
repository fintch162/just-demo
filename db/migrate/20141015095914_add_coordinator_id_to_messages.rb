class AddCoordinatorIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :coordinator_id, :integer
  end
end
