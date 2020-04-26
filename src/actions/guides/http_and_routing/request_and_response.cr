class Guides::HttpAndRouting::RequestAndResponse < GuideAction
  ANCHOR_RUN_CODE_BEFORE_OR_AFTER_ACTIONS_WITH_PIPES = "perma-run-code-before-or-after-actions-with-pipes"
  ANCHOR_HANDLING_RESPONSES                          = "perma-hanlding-responses"
  ANCHOR_REDIRECTING                                 = "perma-redirecting"
  guide_route "/http-and-routing/request-and-response"

  def self.title
    "Requests and Responses"
  end

  def markdown : String
    <<-MD
    ## Handling Requests

    When a request for a path calls an action, the action has access to the request object through a `request` method.
    > The `request` object is an instance of [HTTP::Request](https://crystal-lang.org/api/HTTP/Request.html).

    Lucky also provides access to some helpful methods to determine the requests desired response format.

    * `json?` - true if the client accepts "application/json"
    * `ajax?` - true if the X-Requested-With header is "XMLHttpRequest"
    * `html?` - true if the client accepts HTML
    * `xml?` - true if the client accepts is "application/xml" or "application/xhtml+xml"
    * `plain?` - true if the client accepts is "text/plain"

    You can use these methods to direct the request or return different responses.

    ```crystal
    class Users::Show < BrowserAction
      route do
        if json?
          # The client wants json, so let's return some json
          json(UserSerializer.new(current_user))
        else
          # Just render the page like normal
          html Users::ShowPage
        end
      end
    end
    ```

    ## HTTP Headers

    ### Accessing Headers

    If you need to access or set the headers, you can use `request.headers` or `response.headers`.

    ```crystal
    class Dashboard::Index < BrowserAction
      route do
        remote_ip = request.headers["X-Forwarded-For"]?

        if remote_ip
          plain_text "The remote IP is \#{remote_ip}"
        else
          plain_text "No remote IP found"
        end
      end
    end
    ```

    ### Setting Response Headers

    For things like handling CORS, and many other operations like caching,
    it may be necessary to set response headers. Set these values
    through the `response.headers` object.

    ```crystal
    class Admin::Reports::Show < BrowserAction
      route do
        response.headers["Cache-Control"] = "max-age=150"
        html ShowPage
      end
    end
    ```

    You can read more about working with headers in the [Crystal docs on HTTP::Headers](https://crystal-lang.org/api/0.30.1/HTTP/Headers.html).

    #{permalink(ANCHOR_HANDLING_RESPONSES)}
    ## Handling Responses

    Every action is required to return a response

    These are the built-in Lucky response methods:

    * `html` - render a Lucky::HTMLPage
    * `redirect` - redirect the request to another location
    * `plain_text` - respond with plain text
    * `json` - return a json response
    * `xml` - return an xml response
    * `head` - return a head response with a 204 status
    * `file` - return a file for download

    ```crystal
    class Jobs::Reports::Create < ApiAction
      post "/jobs/reports/" do
        # Run some fancy background job
        if plain?
          # plain text request, return some plain text
          plain_text "Job sent for processing"
        else
          # Respond with HEAD 201
          head 201
        end
      end
    end
    ```

    > The `response` object is an instance of [HTTP::Server::Response](https://crystal-lang.org/api/HTTP/Server/Response.html).

    #{permalink(ANCHOR_REDIRECTING)}
    ## Redirecting

    You can redirect using the `redirect` method:

    > Note that for most methods that link you elsewhere (like `redirect`, or the
    `link` helper in HTML pages), you can pass the action directly if it does not
    need any params. You can see this in the first `redirect` example below.

    ```crystal
    class Users::Create < BrowserAction
      route do
        redirect to: Users::Index # Default status is 302
        redirect to: Users::Show.with(user_id: "user_id") # If the action needs params
        redirect to: "/somewhere_else" # Redirect using a string path
        redirect to: Users::Index, status: 301 # Override status
      end
    end
    ```

    ### Redirect statuses

    The default status for a redirect is `HTTP::Status::FOUND` (302), but if you need a different status code, you can pass any [HTTP Status Enum](https://crystal-lang.org/api/HTTP/Status.html).

    #{permalink(ANCHOR_RUN_CODE_BEFORE_OR_AFTER_ACTIONS_WITH_PIPES)}
    MD
  end
end
