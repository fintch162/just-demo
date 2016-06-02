class AddColumnisInsuranceStudentIdToGallary < ActiveRecord::Migration
  def change
  	add_column :galleries, :instructor_student_id, :integer
  end
end
