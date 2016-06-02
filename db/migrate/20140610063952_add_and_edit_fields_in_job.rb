class AddAndEditFieldsInJob < ActiveRecord::Migration
  def change
  	add_column :jobs, :instructor_name, :string
  	add_column :jobs, :instructor_contact, :string
  	rename_column :jobs, :venue, :other_venue
  	remove_column :jobs, :old_id, :integer
  end
end
