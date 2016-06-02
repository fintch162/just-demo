class AddNoteToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :note, :string
  end
end
