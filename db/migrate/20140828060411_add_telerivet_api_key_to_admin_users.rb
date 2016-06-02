class AddTelerivetApiKeyToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :telerivet_api_key, :string
  end
end
