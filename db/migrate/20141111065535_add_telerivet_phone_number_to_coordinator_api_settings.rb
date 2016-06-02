class AddTelerivetPhoneNumberToCoordinatorApiSettings < ActiveRecord::Migration
  def change
    add_column :coordinator_api_settings, :telerivet_phone_number, :string
  end
end
