class TimeCreateMessageDatatypeChange < ActiveRecord::Migration
  def up
    remove_column :messages, :time_created
    add_column :messages, :time_created, :string
  end

  def down
    remove_column :messages, :time_created
    add_column :messages, :time_created, :string
  end
end
