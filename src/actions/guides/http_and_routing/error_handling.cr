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

    By default Lucky returns a 500 HTML page or JSON response.

    ### Customizing Error Handling

    Let's say you have an error class `MyCustomError` in your app. When this
    error is raised, you want to show a custom error to your users. Open up the
    `Errors::Show` in `src/actions/errors/show.cr`, and add your `handle_error`
    method like this.

    ```crystal
    def handle_error(e : MyCustomError)
      if html?
        render_error_page title: "Custom error message.", status: 418
      else
        json({error: "Oh no!"})
      end
    end
    ```

    If there is no `handle_error` for the exception, it will fallback to the default
    one that is generated with every Lucky project: `handle_error(e : Exception)`.
    You can customize that method however you like!

    ### Error handling in development

    When in development, Lucky uses the
    [ExceptionPage](https://github.com/crystal-loot/exception_page) shard to
    display a helpful page with your stack trace, and exception message. The
    option to display the error page or not is in `config/error_handler.cr`.

    If you need to see how the errors are handled in production (i.e. json
    response for an api). Set the `settings.show_debug_output` option to `false`
    in `config/log_handler.cr`.

    ### Default response codes for Exception classes

    > In general this should be a last resort or for libraries that want to
    provide default behavior. Usually you should use `handle_error` methods in
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
    you have a `handle_error` method that changes it.

    ## Error Reporting

    There's many different services out there where you can ship your exceptions
    off to for better cataloging and searching of the errors.

    In your `src/actions/errors/show.cr` file, there are several different
    `handle_error` methods. When an exception occurs in one of your actions, the
    appropriate method is called passing in the exception. This gives you a
    chance to report on the error however you like.

    ```crystal
    # src/actions/errors/show.cr
    def handle_error(error : MyCustomError)
      ErrorReporter.report(context, error)
      render Errors::ShowPage, status: 500, title: "Oops!"
    end
    ```
    MD
  end
end
