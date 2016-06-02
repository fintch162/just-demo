class RemoveImageFromAward < ActiveRecord::Migration
  def change
    remove_column :awards, :image, :binary
  end
end
