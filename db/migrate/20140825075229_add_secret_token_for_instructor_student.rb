class AddSecretTokenForInstructorStudent < ActiveRecord::Migration
  def change
  	add_column :instructor_students, :secret_token, :string
  	InstructorStudent.reset_column_information
    InstructorStudent.all.each do |inv|
      inv.update_attributes!(:secret_token => Array.new(5){rand(36).to_s(36)}.join)
    end
  end
end
