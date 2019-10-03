class Guides::Logging < GuideAction
  guide_route "/logging"

  def self.title
    "Logging"
  end

  def markdown : String
    <<-MD
    ## Logging

    You can log messages by calling `debug`, `info`, `warn`, or `error` on
    `Lucky.logger`. You can pass in a string or a
    <code>[NamedTuple](https://crystal-lang.org/api/latest/NamedTuple.html)</code>:

    ```crystal
    # Log formatter will receive { message: "My message" }
    Lucky.logger.info("My message")
    # Log formatter will receive { foo: "bar" }
    Lucky.logger.info(foo: "bar")
    ```

    By default, Lucky formats the log output to look like `GET 200 / TIMESTAMP (27.0µs)`. This is broken down in to several parts:

    * The HTTP request method
    * The HTTP server status
    * The requested route
    * The current timestamp of the request (by default only in production)
    * and the elapsed time

    ### Logger Options

    You can change the logger configuration in `config/log_handler.cr`

    ```crystal
    # Show/Hide the current timestamp of the request. By default this is shown only
    # in production
    show_timestamps : Bool

    # Customize how your log is formatted, and what information it shows. By
    # default this is the `DefaultLogFormatter`
    log_formatter : Lucky::LogFormatters::Base

    # An option to turn on/off logging. By default logging is enabled except for
    # when running tests.
    enabled : Bool
    ```

    ## Log Formatters

    To customize your logging output, you can create a custom Log Formatter. Open your `config/log_handler.cr` file to add this option:

    ```crystal
    Lucky::LogHandler.configure do |settings|
      settings.show_timestamps = Lucky::Env.production?
      settings.log_formatter = MyCustomFormatter.new
    end
    ```

    > Note: Be sure to require this new formatter in your stack. Typically this
    is done `src/app.cr`.

    The structure for the formatters is a class that inherits from
    `Lucky::LogFormatters::Base` and defines the `format(context, time, elapsed)
    : String` method. Take a look at this example:

    ```crystal
    class MyCustomFormatter < Lucky::LogFormatters::Base
      def format(context, time, elapsed)
        case context.response.status_code
        when 200..399
          "😁"
        when 400..499
          "😱"
        when 500..599
          "😭"
        else
          "🧐"
        end
      end
    end
    ```

    This method gives you access to the current `context : HTTP::Server::Context`
    which contains the `request` and `response` objects, `time : Time` which is
    the current timestamp, and `elapsed : Time::Span` which is the amount of time
    the entire request took to complete.

    Lucky has 3 helper methods you can use for some helpful formatting as well.

    ```crystal
    # Returns the status_code colorized with green, yellow, or red text based on the range of the code
    colored_status_code(context.response.status_code)

    # Formats the time to ISO_8601_DATE_TIME if the `show_timestamps` option is set to true.
    timestamp(time)

    # Does some fancy math to display the elapsed span in a human readable format
    elapsed_text(elapsed)
    ```
    MD
  end
end
