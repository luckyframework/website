class Guides::HttpAndRouting::HTTPHandlers < GuideAction
  guide_route "/http-and-routing/http-handlers"

  def self.title
    "HTTP Handlers"
  end

  def markdown
    <<-MD
    ## About handlers

    Crystal comes with a module [HTTP::Handler](https://crystal-lang.org/api/HTTP/Handler.html) which is used as middleware for your HTTP Server stack.
    These are classes you create that include the `HTTP::Handler` module to process incoming requests, and return responses.

    ## Built-in handlers

    Lucky comes with some built-in handlers that you can see in your `src/app_server.cr` file under the `middleware` method.
    The order of this middleware stack is the order Lucky will send a web request with the first in the stack getting the initial request, and the last finishing out the stack.

    By default when you generate a full application, your middleware stack will look like this:

    ```crystal
    def middleware
      [
        Lucky::ForceSSLHandler.new,
        Lucky::HttpMethodOverrideHandler.new,
        Lucky::LogHandler.new,
        Lucky::SessionHandler.new,
        Lucky::FlashHandler.new,
        Lucky::ErrorHandler.new(action: Errors::Show),
        Lucky::RouteHandler.new,
        Lucky::StaticFileHandler.new("./public", false),
        Lucky::RouteNotFoundHandler.new,
      ]
    end
    ```

    The `request` object will start in the `Lucky::ForceSSLHandler`, do some processing, then move on to the `Lucky::LogHandler`, and so on.
    In the `Lucky::RouteHandler` it will look for a `Lucky::Action` that mathes the request, run any pipes, then run the action. If no action is found,
    we check to see if there's a static file in `Lucky::StaticFileHandler`. Finally, if no route or file matches the request, we run the `Lucky::RouteNotFoundHandler`.

    ## Creating custom handlers

    Your application may have special requirements like routing legacy URLs, sending bug reporting, CORS, or even doing [HTTP Basic auth](https://en.wikipedia.org/wiki/Basic_access_authentication) while your app is in beta.
    Whatever your use case, creating a custom handler is really easy!

    First we start off by creating a new directory where we can place all of our custom handlers. Create a `src/handlers/` directory, and be sure to require it `src/app.cr`.

    Next, your handler needs 3 things:
    1. It must include `HTTP::Handler`
    2. It must define a `call` method that an argument of `context : HTTP::Server::Context`
    3. It needs to call the `call_next(context)` to go to the next handler in the stack

    ```crystal
    # src/handlers/legacy_redirect_handler.cr
    class LegacyRedirectHandler
      include HTTP::Handler
      LEGACY_ROUTES = {"/old-path" => "/new-path"}

      def call(context : HTTP::Server::Context)
        if new_path = LEGACY_ROUTES[context.request.path]?
          context.response.status_code = 301
          context.response.headers["Location"] = new_path
        else
          # Go to the next handler in the stack
          call_next(context)
        end
      end
    end
    ```

    Lastly, we need to make sure our new custom handler is in our stack. Open up `src/app_server.cr`, and place a new instance in the stack!

    ```crystal
    # src/app_server.cr
    #...
    class App < Lucky::BaseAppServer
      def middleware
        [
          Lucky::HttpMethodOverrideHandler.new,
          Lucky::LogHandler.new,
          LegacyRedirectHandler.new,  # Add this line
          Lucky::SessionHandler.new,
          Lucky::FlashHandler.new,
          Lucky::ErrorHandler.new(action: Errors::Show),
          Lucky::RouteHandler.new,
          Lucky::StaticFileHandler.new("./public", false),
          Lucky::RouteNotFoundHandler.new,
        ]
      end
    end
    ```

    > Note: The order of custom handlers will be completely up to you, but keep in mind the order Lucky placed the built-in handlers.
    MD
  end
end
