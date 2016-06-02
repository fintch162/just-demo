class AddColumnToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :instructor_webhook_api_secret, :string
  end
end
