class AddEmailToStudentContact < ActiveRecord::Migration
  def change
    add_column :student_contacts, :email, :string
  end
end
