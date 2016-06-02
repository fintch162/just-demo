class AddTrPhoneIdAndTrContactIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :tr_phone_id, :string
    add_column :jobs, :tr_contact_id, :string
  end
end
