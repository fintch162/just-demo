class TableSetting < ActiveRecord::Migration
  def change
  	create_table(:table_settings) do |t|
  		t.string   :table_name
  		t.integer  :instructor_id
      t.boolean  :name,           default: true
      t.boolean  :contact,        default: true
      t.boolean  :ic_number,      default: true
      t.boolean  :date_of_birth,  default: true
      t.boolean  :join_date,      default: true
      t.boolean  :description,    default: true
      t.boolean  :ready_for,      default: true
      t.boolean  :training_for,   default: true
      t.boolean  :registered_for, default: true
      t.boolean  :achieved,       default: true
      t.boolean  :month1,         default: true
      t.boolean  :month2,         default: true
      t.boolean  :month3,         default: true
    end
  end
end
