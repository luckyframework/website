class Guides::JsonAndApis::Cors < GuideAction
  guide_route "/json-and-apis/cors"

  def self.title
    "Cross-Origin Resource Sharing (CORS)"
  end

  def markdown
    <<-MD
    ## Handling CORS

    When working with an API, you may need to set some
    [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) headers.
    Doing this in Lucky is pretty easy!

    ### Handler Setup

    We will create a new [handler](#{Guides::HttpAndRouting::HTTPHandlers.path}) for setting
    these headers on every request.

    Start by adding a new folder called `src/handlers/`, and be sure to add a require in `src/app.cr`.
    We can place our new `CORSHandler` in `src/handlers/cors_handler.cr`.

    ```crystal
    # src/handlers/cors_handler.cr
    class CORSHandler
      include HTTP::Handler

      def call(context)
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        context.response.headers["Access-Control-Allow-Headers"] = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range"
        context.response.headers["Access-Control-Allow-Methods"] = "*"
        call_next(context)
      end
    end
    ```

    Lastly, we just need to place this new handler in our stack. Add it in to your
    `src/app_server.cr` just before your `Lucky::RouteHandler`.

    ```crystal
    # src/app_server.cr
    def middleware
      [
        #...
        Lucky::ErrorHandler.new(action: Errors::Show),
        CORSHandler.new,
        Lucky::RouteHandler.new,
        #...
      ]
    end
    ```

    ### Preflight Options

    You may find that you need a little more than a simple setup to handle CORS.
    Some requests may require a preflight `OPTIONS` call, or maybe you need a little more
    control over the header values.

    ```crystal
    # src/handlers/cors_handler.cr
    class CORSHandler
      include HTTP::Handler

      def call(context)
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        context.response.headers["Access-Control-Allow-Credentials"] = "true"
        context.response.headers["Access-Control-Allow-Methods"] = "POST,GET,OPTIONS"
        context.response.headers["Access-Control-Allow-Headers"] = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authentication"

        # If this is an OPTIONS call, respond with just the needed headers and
        # respond with an empty response.
        if context.request.method == "OPTIONS"
          context.response.status = HTTP::Status::NO_CONTENT
          context.response.headers["Access-Control-Max-Age"] = "\#{20.days.total_seconds.to_i}"
          context.response.headers["Content-Type"] = "text/plain"
          context.response.headers["Content-Length"] = "0"
          context
        else
          call_next(context)
        end
      end
    end
    ```

    ### Allowing specific hosts

    Setting the `Access-Control-Allow-Origin` header to `*` will allow any host, but you can
    restrict this with a check against the request `Origin` header.

    ```crystal
    def call(context)
      request_origin = context.request.headers["Origin"]

      context.response.headers["Access-Control-Allow-Origin"] = allowed_origin(request_origin)
      # ... rest of the implementation ...
    end

    private def allowed_origin(request_origin) : String
      origin_allowed = [/\\.lvh\\.me/, /localhost/].find(false) do |pattern|
        pattern === request_origin
      end

      if origin_allowed
        request_origin
      else
        ""
      end
    end
    ```

    ## CORS Example

    Here is a full CORS example. Be sure to read up what each header is used for
    to ensure you're using the correct configuration for your needs.

    ```crystal
    # src/handlers/cors_handler.cr
    class CORSHandler
      include HTTP::Handler
      # Origins that your API allows
      ALLOWED_ORIGINS = [
        # Allows for local development
        /\\.lvh\\.me/,
        /localhost/,
        /127\\.0\\.0\\.1/,

        # Add your production domains here
        # /production\\.com/
      ]

      def call(context)
        request_origin = context.request.headers["Origin"]

        # Setting the CORS specific headers.
        # Modify according to your apps needs.
        context.response.headers["Access-Control-Allow-Origin"] = allowed_origin?(request_origin) ? request_origin : ""
        context.response.headers["Access-Control-Allow-Credentials"] = "true"
        context.response.headers["Access-Control-Allow-Methods"] = "POST,GET,OPTIONS"
        context.response.headers["Access-Control-Allow-Headers"] = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authentication"

        # If this is an OPTIONS call, respond with just the needed headers.
        if context.request.method == "OPTIONS"
          context.response.status = HTTP::Status::NO_CONTENT
          context.response.headers["Access-Control-Max-Age"] = "\#{20.days.total_seconds.to_i}"
          context.response.headers["Content-Type"] = "text/plain"
          context.response.headers["Content-Length"] = "0"
          context
        else
          call_next(context)
        end
      end

      private def allowed_origin?(request_origin)
        ALLOWED_ORIGINS.find(false) do |pattern|
          pattern === request_origin
        end
      end
    end
    ```

    ```crystal
    # src/app.cr
    require "./shards"
    require "./models/*"
    require "./handlers/*"
    #...
    ```

    ```crystal
    # src/app_server.cr
    class AppServer < Lucky::BaseAppServer
      def middleware
        [
          #...
          Lucky::ErrorHandler.new(action: Errors::Show),
          CORSHandler.new,
          Lucky::RouteHandler.new,
          #...
        ]
      end
      #...
    end
    ```
    MD
  end
end
