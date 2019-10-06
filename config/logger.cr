require "file_utils"

# This enables the color output when in development or test mode
# Check out the Colorize docs for more information
# https://crystal-lang.org/api/Colorize.html
Colorize.enabled = !Lucky::Env.production?

logger =
  if Lucky::Env.test?
    # Logs to `tmp/test.log` so you can see what's happening without having
    # a bunch of log output in your specs results.
    FileUtils.mkdir_p("tmp")
    Dexter::Logger.new(
      io: File.new("tmp/test.log", mode: "w"),
      level: Logger::Severity::DEBUG,
      log_formatter: Lucky::PrettyLogFormatter
    )
  elsif Lucky::Env.production?
    # This sets the log formatter to JSON so you can parse the logs with
    # services like Logentries or Logstash.
    #
    # If you want logs like in development use `Lucky::PrettyLogFormatter`.
    Dexter::Logger.new(
      io: STDOUT,
      level: Logger::Severity::INFO,
      log_formatter: Dexter::Formatters::JsonLogFormatter
    )
  else
    # For development, log everything to STDOUT with the pretty formatter.
    Dexter::Logger.new(
      io: STDOUT,
      level: Logger::Severity::DEBUG,
      log_formatter: Lucky::PrettyLogFormatter
    )
  end

Lucky.configure do |settings|
  settings.logger = logger
end

Lucky::LogHandler.configure do |settings|
  # Skip logging static assets in development
  if Lucky::Env.development?
    settings.skip_if = ->(context : HTTP::Server::Context) {
      context.request.method.downcase == "get" &&
      context.request.resource.starts_with?(/\/css\/|\/js\/|\/assets\//)
    }
  end
end

Avram.configure do |settings|
  settings.logger = logger
end
