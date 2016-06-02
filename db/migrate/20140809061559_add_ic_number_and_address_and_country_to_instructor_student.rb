class AddIcNumberAndAddressAndCountryToInstructorStudent < ActiveRecord::Migration
  def change
    add_column :instructor_students, :ic_number, :string
    add_column :instructor_students, :address, :text
    add_column :instructor_students, :country, :string
  end
end
