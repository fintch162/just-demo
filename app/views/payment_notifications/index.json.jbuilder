json.array!(@payment_notifications) do |payment_notification|
  json.extract! payment_notification, :id, :params, :online_payment_id, :status, :transaction_id, :create
  json.url payment_notification_url(payment_notification, format: :json)
end
