# This is used when generating URLs for your application
Lucky::RouteHelper.configure do |settings|
  if LuckyEnv.production?
    # Support for heroku review apps
    if (heroku_app_name = ENV["HEROKU_APP_NAME"]?) && ENV["HEROKU_PR_NUMBER"]?
      settings.base_url = "https://#{heroku_app_name}.herokuapp.com"
    else
      settings.base_uri = ENV.fetch("APP_DOMAIN")
    end
  else
    # Set domain to the default host/port in development/test
    settings.base_uri = "http://localhost:#{Lucky::ServerSettings.port}"
  end
end
