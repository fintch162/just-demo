class AddRegistrationPackageIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :registration_package_id, :integer
  end
end
