class Guides::HttpAndRouting::ErrorHandling < GuideAction
  guide_route "/http-and-routing/error-handling"

  def self.title
    "Error Handling"
  end

  def markdown
    <<-MD
    ## Error Handling

    When an exception is thrown in your code, you don't want your user left with
    a blank page, so Lucky has a built in way of handling these errors.

    ## Customizing Error Handling

    Let's say you have an error class `MyCustomError` in your app. When this
    error is raised, you want to show a custom error to your users. Open up the
    `Errors::Show` in `src/actions/errors/show.cr`, and add your `render`
    method like this.

    ```crystal
    def render(e : MyCustomError)
      if html?
        render_error_page title: "Custom error message.", status: 418
      else
        json({error: "Oh no!"})
      end
    end
    ```

    If there is no `render` for the exception, it will fallback to the default
    one that is generated with every Lucky project: `render(e : Exception)`.
    You can customize that method however you like!

    ## Error handling in development

    When in development, Lucky uses the
    [ExceptionPage](https://github.com/crystal-loot/exception_page) shard to
    display a helpful page with your stack trace, and exception message. The
    option to display the error page or not is in `config/error_handler.cr`.

    If you need to see how the errors are handled in production (i.e. json
    response for an api). Set the `settings.show_debug_output` option to `false`
    in `config/log_handler.cr`.

    ## Default response codes for Exception classes

    > In general this should be a last resort or for libraries that want to
    provide default behavior. Usually you should use `render` methods in
    `Errors::Show` because it is far more customizable and much simpler to work with.

    If you want to return a special http status code for an Exception class you can do this:

    ```crystal
    # Define your custom exception
    class NotAuthorizedError < Exception
      include Lucky::HttpRespondable

      def http_error_code
        403
      end
    end
    ```

    When `NotAuthorizedError` is raised, Lucky will use the defined status code, *unless*
    you have a `render` method that changes it.

    ## Error reporting

    There's many different services out there where you can ship your exceptions
    off to for better cataloging and searching of the errors.

    In your `src/actions/errors/show.cr` file, there is a `report` method.
    By default this does nothing, but you can report the error however
    you want. You can send an email, send the error to one or more services,
    or anything else you want.

    For example, let's use the [Raven shard](https://github.com/sija/raven.cr)
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

    ### Changing how some errors are reported

    You can use method overloading to report some errors differently than others.
    For example, let's say we have a `SuperScaryError` that we want to report
    and also send a text to the CEO about. We can add a `report` method that
    handles that error:

    ```crystal
    def report(error : SuperScaryError)
      NotifyTheBoss.run!
    end
    ```

    Now, all other errors will be reported by `report(error : Exception)`
    but `SuperScaryError` will be handled by `report(error : SuperScaryError)`.

    ### Skipping reporting

    Some errors don't need to be reported. `Errors::Show` has a `dont_report`
    macro that accepts an array of classes that should not be reported. By
    default Lucky does not report `Lucky::RouteNotFoundError` but you can
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
