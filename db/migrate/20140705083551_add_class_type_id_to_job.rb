class AddClassTypeIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :class_type_id, :integer
  end
end
