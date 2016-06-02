class AddBookingStatusTimeToGroupClass < ActiveRecord::Migration
  def change
    add_column :group_classes, :booking_status_time, :datetime
  end
end
