class AddGoogleCliendIdAndSecretToApiSettings < ActiveRecord::Migration
  def change
    add_column :api_settings, :google_client_id, :string
    add_column :api_settings, :google_client_secret, :string
  end
end
