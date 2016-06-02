class AddAllowXfersToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :allow_xfers, :boolean
  end
end
