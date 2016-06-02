class ChangeDatatypeTimeCreatedInMessage < ActiveRecord::Migration
  def up
    remove_column :messages, :time_created
    add_column :messages, :time_created, :datetime
  end

  def down
    remove_column :messages, :time_created
    add_column :messages, :time_created, :datetime
  end
end
