class AddGenderToInstructors < ActiveRecord::Migration
  def change
    add_column :instructors, :gender, :boolean
  end
end