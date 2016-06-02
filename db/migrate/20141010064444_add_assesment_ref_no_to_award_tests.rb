class AddAssesmentRefNoToAwardTests < ActiveRecord::Migration
  def change
    add_column :award_tests, :assesment_ref_no, :string
  end
end
