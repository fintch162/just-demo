class CreateApiSettings < ActiveRecord::Migration
  def change
    create_table :api_settings do |t|
      t.string :telerivet_project_id
      t.string :telerivet_phone_id
      t.string :telerivet_api_key
      t.string :fb_api_url
      t.string :fb_authentication_token

      t.timestamps
    end
  end
end
