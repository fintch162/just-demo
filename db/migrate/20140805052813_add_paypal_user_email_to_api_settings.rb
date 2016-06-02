class AddPaypalUserEmailToApiSettings < ActiveRecord::Migration
  def change
    add_column :api_settings, :paypal_user_email, :string
  end
end
