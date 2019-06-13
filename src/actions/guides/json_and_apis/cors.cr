class Guides::JsonAndApis::Cors < GuideAction
  guide_route "/json-and-apis/cors"

  def self.title
    "Cross-Origin Resource Sharing (CORS)"
  end

  def markdown
    <<-MD
    ## Handling CORS

    When working with an API, you may need to set some [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) headers. Doing this in Lucky is pretty easy!

    ### Basic example

    In your `src/actions/api_action.cr`, you can use a `before` action to set your headers.

    ```crystal
    abstract class ApiAction < Lucky::Action
      before set_cors_headers

      def set_cors_headers
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Headers"] =
          "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range"
        response.headers["Access-Control-Allow-Methods"] = "*"
        continue
      end
    end
    ```

    > Note: the before action method must return `continue`, or a `LuckyWeb::Response`. See [Actions and Routing](#{Guides::HttpAndRouting::RequestAndResponse.path(anchor: Guides::HttpAndRouting::RequestAndResponse::ANCHOR_RUN_CODE_BEFORE_OR_AFTER_ACTIONS_WITH_PIPES)}) for more info.

    ### Complex example

    You may find that you need a little more than a simple setup to handle CORS.
    Some requests may require a preflight `OPTIONS` call. You can check for that request method.

    ```crystal
    def set_cors_headers
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Access-Control-Allow-Credentials"] = "true"
      response.headers["Access-Control-Allow-Methods"] = "POST,GET,OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authentication"

      # If this is an OPTIONS call, respond with just the needed headers and
      # respond with an empty response.
      if request.method == "OPTIONS"
        response.headers["Access-Control-Max-Age"] = "\#{20.days.total_seconds.to_i}"
        head HTTP::Status::NO_CONTENT
      else
        continue
      end
    end
    ```

    ### Allowing specific hosts

    Setting the `Access-Control-Allow-Origin` header to `*` will allow any host, but you can
    restrict this with a check against the request `Origin` header.

    ```crystal
    def set_cors_headers
      request_origin = request.headers["Origin"]

      response.headers["Access-Control-Allow-Origin"] = allowed_origin(request_origin)
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
    abstract class ApiAction < Lucky::Action
      # Origins that your API allows
      ALLOWED_ORIGINS = [
        # Allows for local development
        /\.lvh\.me/,
        /localhost/,
        /127\.0\.0\.1/,

        # Add your production domains here
        # /production\.com/
      ]

      before set_cors_headers

      def set_cors_headers
        request_origin = request.headers["Origin"]

        # Setting the CORS specific headers.
        # Modify according to your apps needs.
        response.headers["Access-Control-Allow-Origin"] = allowed_origin?(request_origin) ? request_origin : ""
        response.headers["Access-Control-Allow-Credentials"] = "true"
        response.headers["Access-Control-Allow-Methods"] = "POST,GET,OPTIONS"
        response.headers["Access-Control-Allow-Headers"] = "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authentication"

        # If this is an OPTIONS call, respond with just the needed headers.
        if request.method == "OPTIONS"
          response.headers["Access-Control-Max-Age"] = 20.days.total_seconds.to_i.to_s
          head HTTP::Status::NO_CONTENT
        else
          continue
        end
      end

      private def allowed_origin?(request_origin)
        ALLOWED_ORIGINS.find(false) do |pattern|
          pattern === request_origin
        end
      end
    end
    ```
    MD
  end
end
