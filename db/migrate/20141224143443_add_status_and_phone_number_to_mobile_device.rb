class AddStatusAndPhoneNumberToMobileDevice < ActiveRecord::Migration
  def change
    add_column :mobile_devices, :status, :string
    add_column :mobile_devices, :phoneNumber, :string
  end
end
