class AddTelerivetPhoneNumberToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :telerivet_phone_number, :string
  end
end
