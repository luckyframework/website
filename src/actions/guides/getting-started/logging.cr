class Guides::GettingStarted::Logging < GuideAction
  guide_route "/getting-started/logging"

  def self.title
    "Logging"
  end

  def markdown : String
    <<-MD
    ## Configuration

    Lucky uses [Dexter](https://github.com/luckyframework/dexter) to handle all logging.
    The configuration is in `config/logger.cr` where you will find the setup for the Lucky logger,
    some options for the LogHandler, and logging for Avram.

    Lucky sets up a different configuration based on the environment your app is running in.

    * In the `test` environment, the logger uses the `DEBUG` level, and writes to a temp file (`tmp/test.log`)
      so we don't muddle your spec output.
    * In `production`, the logger uses the `INFO` level, and writes to `STDOUT` using a json formatter
      for the output.
    * Finally, in `development`, the logger uses the `DEBUG` level, and writes to `STDOUT` using a custom pretty
      formatter

    All of these settings can be changed in `config/logger.cr`.

    > When writing to `STDOUT`, the colors are turned on for development. If you'd like to disable color,
    > open `config/colors.cr`, and set `Colorize.enabled = false`.

    ### Logger Severity

    There are several different severity levels you can choose. These are all defined in the [Crystal Logger](https://crystal-lang.org/api/latest/Logger.html).

    * `Logger::Severity::DEBUG` - Show information like which page was rendered, what actions were called, and other debug info.
    * `Logger::Severity::ERROR` - Only log exception errors.
    * `Logger::Severity::FATAL` - Only log errors that cause the app to crash.
    * `Logger::Severity::INFO` - This includes HTTP method, path, and time.
    * `Logger::Severity::UNKNOWN` - It is unknown
    * `Logger::Severity::WARN` - Information like deprecation notices, and potential application oddities like retrying a process.


    ## Logging Data

    You can access the logger from anywhere in your app using the `Lucky.logger` method. This gives you
    methods based on severity to log to. (e.g. `Lucky.logger.debug`, `Lucky.logger.info`)

    ```crystal
    class Dashboard::Index < BrowserAction
      get "/dashboard" do
        # Pass a String to log that message
        Lucky.logger.info("User has been logged in successsfully")
        html IndexPage
      end
    end
    ```

    For more key/value logging, you can pass a `NamedTuple` and Lucky will format the data for you.

    ```crystal
    class LegacyRedirectHandler
      def call(context)

        # ▸ Message Calling LegacyRedirectHandler. Last thing i had for lunch 🌮
        Lucky.logger.debug(
          message: "Calling LegacyRedirectHandler",
          last_thing_i_had_for_lunch: "🌮"
        )
        call_next(context)
      end
    end
    ```

    ## Custom Log Format

    Lucky gives you 2 different formatters by default; the `Lucky::PrettyLogFormatter`, and
    the `Dexter::Formatters::JsonLogFormatter`. These are the formats used in development, and production,
    respectively.

    For custom formatting, you would create a new struct that inherits from `Dexter::Formatters::BaseLogFormatter`,
    then define a `format` method.

    ```crystal
    # src/log_formatters/my_custom_log_formatter.cr
    struct MyCustomLogFormatter < Dexter::Formatters::BaseLogFormatter
      # You have access to these methods
      #   severity : Logger::Severity
      #   timestamp : Time
      #   progname : String
      #   io : IO
      def format(data : NamedTuple) : Nil
        io << "The time is \#{timestamp}\\n"
        data.each do |key, value|
          io << "\#{Wordsmith::Inflector.humanize(key)} => \#{value}"
        end
        return
      end
    end
    ```

    Now you can update your default logger to use this format in `config/logger.cr`. Change `log_formatter: Lucky::PrettyLogFormatter` to `log_formatter: MyCustomLogFormatter`.

    > The recommended location for this would be in `src/log_formatters/`.  Be sure to require this file in your `src/app.cr`.

    ## LogHandler

    Lucky includes a `LogHandler` middleware in `src/app_server.cr` that logs basic request information like
    the request method, request path, response status, and the duration of the request.

    ### skip_if

    The `skip_if` option is configured in `config/logger.cr` to allow you to skip logging certain requests that
    come in to your application. By default, this will skip all `GET` requests to files in any path starting with
    `/css`, `/js`, or `/assets`.

    This may be a good option to also skip logging if a token is passed in the query params, or any `POST` request
    that could contain sensitive data.
    MD
  end
end
