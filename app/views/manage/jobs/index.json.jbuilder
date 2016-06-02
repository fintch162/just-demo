json.array!(@jobs) do |job|
  json.extract! job, :id, :post_date, :instructor_id, :preferred_time, :referral, :par_pax, :fee_total, :age_group, :class_level, :start_date, :class_type, :other_venue, :lead_email, :lead_contact, :lead_name, :day_of_week, :customer_contact, :customer_name, :first_attendance, :goggles_status, :lock_date, :message_to_instructor, :job_status, :message_to_customer, :coordinator_notes, :lead_info, :lead_address, :lesson_count, :fee_type_id, :class_time, :completed_by, :venue_id, :show_names, :free_goggles, :lady_instructor, :instructor_name, :instructor_contact
  json.url job_url(job, format: :json)
end
