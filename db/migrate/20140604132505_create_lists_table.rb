class CreateListsTable < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :title
      t.string :type
    end
    add_index :lists, :type
  end
end
