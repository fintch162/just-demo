class RemoveMerchantIdFromReddotCredentials < ActiveRecord::Migration
  def change
  	rename_column :reddot_credentials, :merchant_ud, :merchant_id

    add_column :reddot_credentials, :name, :string
  end
end
