class CreateReddotCredentials < ActiveRecord::Migration
  def change
    create_table :reddot_credentials do |t|
      t.string :url
      t.string :merchant_ud
      t.string :key

      t.timestamps
    end
  end
end
