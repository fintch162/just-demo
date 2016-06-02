class CreateTermsAndConditions < ActiveRecord::Migration
  def change
    create_table :terms_and_conditions do |t|
      t.string :status
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
