class AddPaypalKeyAndXfersKeyToApiSettings < ActiveRecord::Migration
  def change
    add_column :api_settings, :paypal_key, :string
    add_column :api_settings, :xfers_key, :string
  end
end
