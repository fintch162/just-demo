class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :to
      t.text :message_description

      t.timestamps
    end
  end
end
