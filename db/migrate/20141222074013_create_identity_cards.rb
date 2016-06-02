class CreateIdentityCards < ActiveRecord::Migration
  def change
    create_table :identity_cards do |t|
      t.string :name

      t.timestamps
    end
  end
end
