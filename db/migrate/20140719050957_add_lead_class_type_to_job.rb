class AddLeadClassTypeToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :lead_class_type, :integer
  end
end
