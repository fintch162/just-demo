class AddShortNameToInstructors < ActiveRecord::Migration
  def change
    add_column :instructors, :short_name, :string
  end
end
