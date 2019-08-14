class AppServer < Lucky::BaseAppServer
  def middleware
    [
      Lucky::ForceSSLHandler.new,
      Lucky::HttpMethodOverrideHandler.new,
      Lucky::LogHandler.new,
      Lucky::SessionHandler.new,
      Lucky::FlashHandler.new,
      Lucky::ErrorHandler.new(action: Errors::Show),
      Lucky::RouteHandler.new,
      CacheControlHandler.new,
      Lucky::StaticFileHandler.new("./public", false),
      LegacyRedirectHandler.new,
      Lucky::RouteNotFoundHandler.new,
    ]
  end

  def protocol
    "http"
  end

  def listen
    # Learn about bind_tcp: https://tinyurl.com/bind-tcp-docs
    server.bind_tcp(host, port, reuse_port: false)
    server.listen
  end
end
