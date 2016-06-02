class AddColumnToAward < ActiveRecord::Migration
  def change
    add_column :awards, :short_name, :string
  end
end
