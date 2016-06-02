class ChangeColumnGenderToInstructor < ActiveRecord::Migration
  def change
    change_column :instructors, :gender, :string
  end
end
