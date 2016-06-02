class CreateStudentIdentities < ActiveRecord::Migration
  def change
    create_table :student_identities do |t|
      t.string :identity_doc

      t.timestamps
    end
  end
end
