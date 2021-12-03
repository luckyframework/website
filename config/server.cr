# Here is where you configure the Lucky server
#
# Look at config/route_helper.cr if you want to change the domain used when # generating links with `Action.url`.
Lucky::Server.configure do |settings|
  if LuckyEnv.production?
    settings.secret_key_base = secret_key_from_env
    settings.host = "0.0.0.0"
    settings.port = ENV["PORT"].to_i
    settings.gzip_enabled = true
  else
    settings.secret_key_base = "2/4teCSDIg6iSpVHdcHyY60N7vSK4+ao4vQUgdss11c="
    # Change host/port in config/watch.yml
    # Alternatively, you can set the PORT env to set the port
    settings.host = Lucky::ServerSettings.host
    settings.port = Lucky::ServerSettings.port
  end
end

Lucky::ForceSSLHandler.configure do |settings|
  settings.enabled = LuckyEnv.production?
  settings.strict_transport_security = {max_age: 1.year, include_subdomains: true}
end

# Set a uniuqe ID for each HTTP request.
Lucky::RequestIdHandler.configure do |settings|
  # To enable the request ID, uncomment the lines below.
  # You can set your own custom String, or use a random UUID.
  #
  if LuckyEnv.development?
    settings.set_request_id = ->(_context : HTTP::Server::Context) {
      UUID.random.to_s
    }
  end
end

private def secret_key_from_env
  ENV["SECRET_KEY_BASE"]? || raise_missing_secret_key_in_production
end

private def raise_missing_secret_key_in_production
  raise "Please set the SECRET_KEY_BASE environment variable. You can generate a secret key with 'lucky gen.secret_key'"
end
