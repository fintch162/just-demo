class CreateLightningRisks < ActiveRecord::Migration
  def change
    create_table :lightning_risks do |t|
      t.string :location
      t.string :risk
      t.string :time

      t.timestamps
    end
  end
end
