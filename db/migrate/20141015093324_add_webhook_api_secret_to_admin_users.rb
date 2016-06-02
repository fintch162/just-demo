class AddWebhookApiSecretToAdminUsers < ActiveRecord::Migration
  def change
    add_column :coordinator_api_settings, :webhook_api_secret, :string
  end
end
