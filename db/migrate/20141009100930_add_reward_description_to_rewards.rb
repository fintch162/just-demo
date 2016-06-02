class AddRewardDescriptionToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :reward_description, :text
  end
end
