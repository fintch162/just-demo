class AddPositionToAwards < ActiveRecord::Migration
  def change
    add_column :awards, :position, :integer
  end
end
