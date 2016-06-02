class DropTableInstructorStudetnGroupClass < ActiveRecord::Migration
  def up
    drop_table :intructor_student_group_classes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
