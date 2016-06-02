class AddBookingStatusToGroupClass < ActiveRecord::Migration
  def change
    add_column :group_classes, :booking_status, :boolean
  end
end
