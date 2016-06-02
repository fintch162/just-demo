class ChangeColumnNameForContact < ActiveRecord::Migration
  def change
    change_column :contacts, :phone_number, :string
    change_column :contacts, :contact_id, :string
  end
end
