json.array!(@award_tests) do |award_test|
  json.extract! award_test, :id, :test_date, :test_time, :award_id, :venue_id, :assessor
  json.url award_test_url(award_test, format: :json)
end
