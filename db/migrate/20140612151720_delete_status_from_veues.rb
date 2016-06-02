class DeleteStatusFromVeues < ActiveRecord::Migration
  def change
    remove_column :venues, :status
  end
end
