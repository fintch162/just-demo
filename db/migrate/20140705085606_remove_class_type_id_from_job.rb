class RemoveClassTypeIdFromJob < ActiveRecord::Migration
  def change
    remove_column :jobs, :class_type_id, :integer
  end
end
