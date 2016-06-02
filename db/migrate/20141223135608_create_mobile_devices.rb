class CreateMobileDevices < ActiveRecord::Migration
  def change
    create_table :mobile_devices do |t|
      t.string :device_model_name
      t.string :device_registration_id

      t.timestamps
    end
  end
end
