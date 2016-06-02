json.array!(@instructor_students) do |instructor_student|
  json.extract! instructor_student, :id, :student_name, :age, :gender, :contact, :job_id, :date_of_birth
  json.url instructor_student_url(instructor_student, format: :json)
end
