class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.integer :job_id
      t.string :name
      t.integer :age
      t.string :sex

      t.timestamps
    end
  end
end
