class CreateStudentContacts < ActiveRecord::Migration
  def change
    create_table :student_contacts do |t|
      t.integer :instructor_student_id
      t.string :relationship
      t.string :name
      t.string :contact
      t.boolean :primary_contact

      t.timestamps
    end
  end
end
