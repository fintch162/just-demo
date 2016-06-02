json.array!(@fees) do |fee|
  json.extract! fee, :id, :payment_date, :course_type, :monthly_detail, :amount, :course_detail
  json.url fee_url(fee, format: :json)
end
