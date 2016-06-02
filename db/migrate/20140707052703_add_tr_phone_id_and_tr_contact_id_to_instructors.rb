class AddTrPhoneIdAndTrContactIdToInstructors < ActiveRecord::Migration
  def change
    add_column :instructors, :tr_phone_id, :string
    add_column :instructors, :tr_contact_id, :string
  end
end
