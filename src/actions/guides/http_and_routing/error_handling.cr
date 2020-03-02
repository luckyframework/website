class Guides::HttpAndRouting::ErrorHandling < GuideAction
  ANCHOR_RENDERABLE_ERRORS         = "perma-renderable-errors"
  ANCHOR_REPORTING                 = "perma-reporting"
  ANCHOR_CUSTOMIZING_ERROR_DISPLAY = "perma-customizing-error-display"
  guide_route "/http-and-routing/error-handling"

  def self.title
    "Error Handling"
  end

  def markdown : String
    <<-MD
    ## How Lucky renders errors

    When an error occurs, the `Lucky::ErrorHandler` calls the auto-generated
    `Errors::Show` action in `src/actions/errors/show.cr`.

    The `Errors::Show` action has 3 key methods:

    * `render(error)`
    * `default_render(error)`
    * `report(error)`

    ### render

    First, the `Errors::Show` action will try to find a matching `render`
    method. The `render` methods take the error as an argument and uses [method
    overloading](https://crystal-lang.org/reference/syntax_and_semantics/overloading.html)
    to find a match. If one matches, the error will be rendered.

    For example, if `MyCustomError` is raised, and there is a method for
    handling it, that method will be used and `default_render` will not be
    called:

    ```crystal
    def render(error : MyCustomError)
      error_html message: "Super Custom", status: 418
    end
    ```

    `error_html` is an automatically generated method on `Errors::Show` that
    shows an HTML page. You can customize it however you want. You can learn
    more about how to [customize how errors are displayed](##{ANCHOR_CUSTOMIZING_ERROR_DISPLAY})
    later in the guide.

    ### default_render

    If no `render` method matches then the `default_render` method will be
    used. This method will send a `500` HTTP status code and either an HTML
    page or a JSON response depending on the client's desired format. If your
    app is using API mode, it will only send JSON and not an HTML page.

    You can learn more about how to [customize how errors are
    displayed](##{ANCHOR_CUSTOMIZING_ERROR_DISPLAY}) later in the guide.

    ### report

    This method handles reporting the error. We'll talk about this more in
    the section on [reporting errors](##{ANCHOR_REPORTING})

    ## Error handling in development

    When using a browser with Lucky in development mode, Lucky uses the
    [ExceptionPage shard](https://github.com/crystal-loot/exception_page) to
    display a helpful page with your stack trace, and exception message.

    When using JSON, Lucky will render errors as JSON whether in development or
    production.

    ### Seeing the error page your users will see

    Sometimes in development you want to see the page your users will see instead
    of the debug page.

    To do so, change the the `settings.show_debug_output` option to `false`:

    ```crystal
    # config/error_handler.cr
    Lucky::ErrorHandler.configure do |settings|
      settings.show_debug_output = false
    end
    ```

    Remember to change it back once you're done so you can see the debug page.

    #{permalink(ANCHOR_CUSTOMIZING_ERROR_DISPLAY)}
    ## Customizing how errors are displayed

    Let's say you have an error class `MyCustomError` in your app. When this
    error is raised, you want to show a custom error to your users. Open up the
    `Errors::Show` in `src/actions/errors/show.cr`, and add your `render`
    method like this.

    ```crystal
    def render(error : MyCustomError)
      if html?
        error_html message: "Custom error message.", status: 418
      else
        error_json message: "Custom error", status: 418
      end
    end
    ```

    If there is no `render` for the exception, it will fallback to the
    default one that is generated with every Lucky project: `default_render(error :
    Exception)`. You can customize that method in the same way by changing
    the message or status codes:

    ```crystal
    def default_render(error : Exception)
      error_json "Something went very very wrong", status: 500
    end
    ```

    ### Customizing errors for just one format

    You can customize an error for just one format if you'd like:

    ```crystal
    def render(error : ThisIsOnlyImportantForJsonError)
      if json?
        error_json "Something for JSON clients", status: 418
      end
    end
    ```

    If the client wants JSON back, it will get this error message, otherwise
    the method will return `nil` and Lucky will fall back to using the
    `default_render` method.

    ### Customizing the error page/JSON

    Lucky generates `error_json` and `error_html` methods in `Errors::Show`.
    These methods and the pages/serializers they call can be customized.

    For example, `error_html` renders `Errors::ShowPage`. You can change that
    page's styles and content in `src/pages/errors/show_page.cr`.

    ## Errors that Lucky handles out of the box

    Lucky will also handle a few errors out of the box. For example,
    `Lucky::RouteNotFoundError` will return a 404:

    ```crystal
    def render(error : Lucky::RouteNotFoundError)
      if html?
        error_html "Sorry, we couldn't find that page.", status: 404
      else
        error_json "Not found", status: 404
      end
    end
    ```

    If you open `src/actions/errors/show_page.cr`, you'll see the other errors
    that Lucky handles by default.

    One of special note is the `Lucky::RenderableError`. We'll talk about
    these more in the section on [renderable
    errors](##{ANCHOR_RENDERABLE_ERRORS})

    #{permalink(ANCHOR_RENDERABLE_ERRORS)}
    ## Renderable errors

    > In general this should be a last resort or for libraries that want to
    provide default behavior for errors. Usually you should use `render`
    methods in `Errors::Show` because it is more customizable and
    simpler to work with.

    Lucky comes with a `Lucky::RenderableError` module that can be included in
    errors so that Lucky knows what the status code and message should be.
    Errors with `Lucky::RenderableError` must have a `renderable_status` and
    `renderable_message` method defined.

    By default, `Lucky::RenderableError`s are handled with the `render(error
    : Lucky::RenderableError)` method included in all new Lucky projects.

    It looks something like this:

    ```crystal
    def render(error : Lucky::RenderableError)
      if html?
        error_html DEFAULT_MESSAGE, status: error.renderable_status
      else
        error_json error.renderable_message, status: error.renderable_status
      end
    end
    ```

    If you want to make it so your error is rendered with this method,
    you can do this:

    ```crystal
    # Define your custom exception
    class NotAuthorizedError < Exception
      include Lucky::RenderableError

      def renderable_status
        403
      end

      def renderable_message
        "Not authorized"
      end
    end
    ```

    When `NotAuthorizedError` is raised, Lucky will use the defined status
    code and message, *unless* you have a `render` method for the error
    (`render(error : NotAuthorizedError)`).

    #{permalink(ANCHOR_REPORTING)}
    ## Reporting errors

    In your `src/actions/errors/show.cr` file, there is a `report` method.
    By default this method is empty, but you can change it to report the
    error however you want. You can send an email, send the error to one or
    more services, or anything else you want.

    ### Example of reporting to Sentry

    Let's use the [Raven shard](https://github.com/sija/raven.cr)
    to send an error report to [Sentry](https://sentry.io/):

    ```crystal
    # src/actions/errors/show.cr
    def report(error : Exception)
      Raven.capture(error)
    end
    ```

    This will send the error report to Sentry. See the [Raven
    README](https://github.com/sija/raven.cr) to learn more about installing
    and how to customize error reporting with Sentry.

    ### Reporting some errors differently

    You can use method overloading to report some errors differently than
    others. For example, let's say we have a `SuperScaryError` that we want
    to report by sending a text to the CEO. We can add a `report` method that
    handles that error:

    ```crystal
    def report(error : SuperScaryError)
      NotifyTheBoss.run!
    end
    ```

    Now `SuperScaryError` will be handled by `report(error :
    SuperScaryError)`, and all other errors will be handled by the regular
    `report(error : Exception)`.

    ### Skipping reporting

    Some errors don't need to be reported. `Errors::Show` has a `dont_report`
    macro that accepts an array of classes that should not be reported. By
    default Lucky does not report `Lucky::RouteNotFoundError`, but you can
    add any errors there that you don't want reported.

    ```
    dont_report [
      Lucky::RouteNotFoundError,
      MyCustomError
    ]
    ```
    MD
  end
end
