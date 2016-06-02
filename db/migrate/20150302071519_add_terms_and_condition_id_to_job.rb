class AddTermsAndConditionIdToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :terms_and_condition_id, :integer
  end
end
