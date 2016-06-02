class CreateJoinJobTermsAndCondition < ActiveRecord::Migration
  def change
    create_table :job_terms_and_conditions do |t|
    	t.belongs_to :job
      t.belongs_to :terms_and_condition
    end
  end
end
