class AddGoogleSynchEmailToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users, :google_synch_email, :string
  end
end
