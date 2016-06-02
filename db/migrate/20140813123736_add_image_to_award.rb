class AddImageToAward < ActiveRecord::Migration
  def change
    add_column :awards, :image, :binary
  end
end
