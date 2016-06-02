class CreateCoordinatorApiSettings < ActiveRecord::Migration
  def change
    create_table :coordinator_api_settings do |t|
      t.integer :coordinator_id
      t.string :telerivet_api_key
      t.string :telerivet_project_id
      t.string :telerivet_phone_id

      t.timestamps
    end
  end
end
