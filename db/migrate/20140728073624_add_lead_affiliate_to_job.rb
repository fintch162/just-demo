class AddLeadAffiliateToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :lead_affiliate, :string
  end
end
