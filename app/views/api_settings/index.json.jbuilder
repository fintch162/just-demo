json.array!(@api_settings) do |api_setting|
  json.extract! api_setting, :id, :telerivet_project_id, :telerivet_phone_id, :telerivet_api_key, :fb_api_url, :fb_authentication_token
  json.url api_setting_url(api_setting, format: :json)
end
