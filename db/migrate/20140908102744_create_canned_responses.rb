class CreateCannedResponses < ActiveRecord::Migration
  def change
    create_table :canned_responses do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
