class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :job_ref
      t.integer :old_id
      t.datetime :post_date
      t.integer :instructor_id
      t.string :preferred_time
      t.integer :referral
      t.integer :par_pax
      t.integer :fee_total
      t.string :age_group
      t.string :class_level
      t.date :start_date
      t.string :class_type
      t.string :venue
      t.string :lead_email
      t.string :lead_contact
      t.string :lead_name
      t.integer :day_of_week
      t.string :customer_contact
      t.string :customer_name
      t.string :first_attendance
      t.string :goggles_status
      t.boolean :lock_date
      t.text :message_to_instructor
      t.string :job_status
      t.text :message_to_customer
      t.text :coordinator_notes
      t.text :lead_info
      t.text :lead_address
      t.integer :lesson_count
      t.string :fee_structure
      t.time :class_time
      t.date :completed_by
      t.integer :venue_id
      t.boolean :show_names
      t.boolean :free_goggles
      t.boolean :lady_instructor

      t.timestamps
    end
  end
end
