class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.references :group_class, index: true

      t.timestamps
    end
  end
end
