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
    * `plain_text` - respond with plain text with `text/plain` Content-Type.
    * `json` - return a JSON response with `application/json` Content-Type.
    * `xml` - return an XML response with `text/xml` Content-Type.
    * `head` - return HTTP HEAD response
    * `file` - return a file for download
    * `component` - render a [Component](#{Guides::Frontend::RenderingHtml.path(anchor: Guides::Frontend::RenderingHtml::ANCHOR_COMPONENTS)}).

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

    ### Rendering a file

    The `file` method can be used to return a file and it's contents to the browser, or render the contents of the file
    inline to a web browser.

    ```crystal
    class Reports::Show < BrowserAction

      get "/reports/sales" do
        file "/path/to/reports.pdf",
            disposition: "attachment",
            filename: "report-\#{Time.utc.month}.pdf",
            content_type: "application/pdf"
      end
    end
    ```

    ### Rending components

    The `component` method allows you to return the HTML generated from a specific component. This can be used in place
    of rendering an entire HTML page which can be useful for loading dynamic HTML on your front-end.

    ```crystal
    # src/components/comment_component.cr
    class CommentComponent < BaseComponent
      needs comment : Comment

      def render
        para(comment.text)
      end
    end

    # src/actions/api/comments/show.cr
    class Api::Comments::Show < ApiAction
      get "/comments/:id" do
        comment = CommentQuery.new.find(id)

        component CommentComponent, comment: comment
      end
    end
    ```

    In this example, you could make a javascript call to this `/comments/123` endpoint which would return the HTML just for that comment.
    This allows you to build out the HTML using Lucky's type-safe builder, but also injecting dynamic HTML in to your page.

    ### Custom responses

    Lucky provides many different built in responses for automatically setting the appropriate Content-Type header for you.
    When you need to respond with a non-standard Content-Type, you can use the `send_text_response` method directly.

    ```crystal
    class Playlists::Index < BrowserAction

      get "/playlist.m3u8" do
        playlist = "..."
        send_text_response(playlist, "application/x-mpegURL", status: 200)
      end
    end
    ```

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

    ### Redirect back

    `redirect_back` allows an action to send the user back to where they made the request from. This is really useful in situations like submitting
    a lead form where the app might have it in several locations but the app doesn't need to take them anywhere in particular after they submit it.
    Rather than sending the user to a specific place after submitting the form, we can now send them back to where they originally submitted it.

    ```crystal
    class NewsletterSignupsCreate < BrowserAction
      post "/newsletter/signup" do
        # do the signup code
        redirect_back fallback: Home::Index
      end
    end
    ```

    > The `fallback` argument is required due to the HTTP Referer being potentially nil.

    #{permalink(ANCHOR_RUN_CODE_BEFORE_OR_AFTER_ACTIONS_WITH_PIPES)}
    MD
  end
end
