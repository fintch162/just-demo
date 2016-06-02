class AddRefreshTokenToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :google_refresh_token, :string
  end
end
