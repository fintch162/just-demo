class AddAdminUserIdToAwardTest < ActiveRecord::Migration
  def change
    add_column :award_tests, :admin_user_id, :integer
  end
end
