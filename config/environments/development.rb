Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  Time::DATE_FORMATS[:non_military_time] = "%I:%M %p"
  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  #Paperclip video options
  Paperclip.options[:command_path] = "/usr/bin/"
  # Paperclip.options[:command_path] = "/home/tps/bin/"


  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.asset_host = 'http://localhost:3000/assets'
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.delivery_method = :letter_opener
  #  config.action_mailer.smtp_settings = {
  #   # :address              => "smtp.gmail.com",
  #   # :port                 => 587,
  #   # :domain               => 'greyvoid.com',
  #   # :user_name            => 'divyang@greyvoid.com',
  #   # :password             => 'airpilot',
  #   # :authentication       => 'plain',
  #   # :enable_starttls_auto => true
  # }
  Paypal.sandbox!

  # ENV["GOOGLE_CLIENT_ID"] = ApiSetting.first.google_client_id #'1016197065285-a6e44r6kbar2nuckc2bi170j4grf6jff.apps.googleusercontent.com'
  # ENV["GOOGLE_CLIENT_SECRET"] = ApiSetting.first.google_client_secret #'eLXV7LNU5eGqwSCwBZXIujZM'

  # ENV["GOOGLE_CLIENT_ID"] = '607220699271-pardnhga4v6ggujeargndikjvlj1b1r3.apps.googleusercontent.com'
  # ENV["GOOGLE_CLIENT_SECRET"] = '1YVsLfqVYc2iKpf6zisxPjmy'
end
