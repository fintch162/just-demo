json.array!(@message_templates) do |message_template|
  json.extract! message_template, :id, :job_status, :has_instructor, :has_customer, :template_body
  json.url message_template_url(message_template, format: :json)
end
