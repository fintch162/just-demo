json.array!(@manual_payments) do |manual_payment|
  json.extract! manual_payment, :id, :job_id, :amount, :payment_method, :goggles_status
  json.url manual_payment_url(manual_payment, format: :json)
end
