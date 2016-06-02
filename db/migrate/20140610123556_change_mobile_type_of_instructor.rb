class ChangeMobileTypeOfInstructor < ActiveRecord::Migration
  def change
  	change_column :instructors, :mobile, :string
  end
end
