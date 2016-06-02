Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ApiSetting.first.google_client_id, ApiSetting.first.google_client_secret, {:scope => "email, profile, https://www.google.com/m8/feeds",prompt: 'consent'}
  on_failure { |env| Instructor::SynchronizeContactsController.action(:google_oauth2_fail).call(env) }	
end