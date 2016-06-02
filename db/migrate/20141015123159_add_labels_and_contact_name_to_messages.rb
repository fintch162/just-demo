class AddLabelsAndContactNameToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :labels, :string
    add_column :messages, :contact_name, :string
  end
end
