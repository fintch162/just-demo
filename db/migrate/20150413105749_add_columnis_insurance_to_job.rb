class AddColumnisInsuranceToJob < ActiveRecord::Migration
  def change
  	add_column :jobs, :is_insurance, :boolean
  end
end
