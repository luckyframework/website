class Guides::GettingStarted::Logging < GuideAction
  guide_route "/getting-started/logging"

  def self.title
    "Logging"
  end

  def markdown : String
    <<-MD
    ## Configuration

    Lucky uses [Dexter](https://github.com/luckyframework/dexter) to handle all logging.
    Log configuration is in `config/log.cr`.

    Lucky sets up a different configuration based on the environment your app is running in.

    * In the `test` environment, the logger uses the `DEBUG` level, and writes to a temp file (`tmp/test.log`)
      instead of `STDOUT`.
    * In `production`, the logger uses the `INFO` level, and writes to `STDOUT` using a json formatter
      for the output.
    * Finally, in `development`, the logger uses the `DEBUG` level, and writes to `STDOUT` using a custom pretty
      formatter.

    All of these settings can be changed in `config/log.cr`.

    > When writing to `STDOUT`, the colors are turned on for development. If you'd like to disable color,
    > open `config/colors.cr`, and set `Colorize.enabled = false`.

    ### Configuration using Dexter

    [Dexter](https://github.com/luckyframework/dexter) is a Lucky library that
    makes it simpler to configure logging in a type-safe way. It also adds some
    methods and formatters we'll go into more later in the guide.

    `{LogClass}.dexter.configure` allows for configuring the [Severity/level](https://crystal-lang.org/api/latest/Log/Severity.html) that
    the log should handle. It also accepts a second optional argument for
    setting the [Log::Backend](https://crystal-lang.org/api/latest/Log/Backend.html).

    Calling `{LogClass}.dexter.configure` will configure the Log and all its children.

    If the `backend` argument is not passed, the Log's backend will not be changed.
    Instead it will use the Log's backend for all its children.

    ```
    backend = Log::IOBackend.new
    # Pass a Log::Severity like :error, :none, or :debug.
    # You usually want to pass a backend to the top-level `Log` or logs
    # will not write to anything.
    Log.dexter.configure(:info, Log::IOBackend.new)

    # LogToIgnore and its children will not log anything
    LogToIgnore.dexter.configure(:none)

    # LogEverything and its children will log everything because `:debug`
    # is the lowest level severity
    LogEverything.dexter.configure(:debug)
    ```

    ## Logging Data

    You can access the logger from anywhere in your app by calling
    `info|warn|debug` or one of the other
    [`Log::Severity`](https://crystal-lang.org/api/latest/Log/Severity.html)
    levels on `Log`.

    ```crystal
    class Dashboard::Index < BrowserAction
      get "/dashboard" do
        # Pass a String to log that message
        Log.info { "\#{current_user.email} view the Dashboard" }
        html IndexPage
      end
    end
    ```

    ### Lucky/Dexter specific Log methods

    It is often useful to log key/value data so that it is easier to parse and
    search logs in production.

    For logging key/value data you can return a `NamedTuple` or `Hash` in the block.

    ```crystal
      Log.dexter.debug do
        {
          message: "Calling LegacyRedirectHandler",
          last_thing_i_had_for_lunch: "🌮"
        }
      end
    ```

    ### Logger Severity

    There are several different severity levels you can choose. These are all
    defined in the [Crystal Log::Severity enum](https://crystal-lang.org/api/latest/Log/Severity.html).

    ## LogHandler

    Lucky includes a `LogHandler` middleware in `src/app_server.cr` that logs
    basic request information like the request method, request path, response
    status, and the duration of the request.

    ### skip_if

    The `skip_if` option is configured in `config/log.cr` to allow you to
    skip logging certain requests that come in to your application.

    By default, Lucky will not log requests for static assets.

    You might use `skip_if` to skip logging sensitive data or requests to
    certain paths.
    MD
  end
end
