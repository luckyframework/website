class Guides::HttpAndRouting::RequestAndResponse < GuideAction
  ANCHOR_RUN_CODE_BEFORE_OR_AFTER_ACTIONS_WITH_PIPES = "perma-run-code-before-or-after-actions-with-pipes"
  ANCHOR_HANDLING_RESPONSES                          = "perma-hanlding-responses"
  ANCHOR_REDIRECTING                                 = "perma-redirecting"
  ANCHOR_HTML_WITH_CUSTOM_STATUS                     = "perma-html-with-custom-status"
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
    * `multipart?` - true if the client accepts starts with "multipart/form-data"

    You can use these methods to direct the request or return different responses.

    ```crystal
    class Users::Show < BrowserAction
      get "/me" do
        if json?
          # The client wants json, so let's return some json
          json(UserSerializer.new(current_user))
        else
          # Just render the page like normal
          html Users::ShowPage, user: current_user
        end
      end
    end
    ```

    ### Setting accepted request formats

    By default, generated Lucky apps set some helpful boundaries around what formats each action in your application can support.  These can be overriden in specific actions with the `accepted_formats` method.

    For example, API actions only support JSON requests. Because only one format is specified as accepted, it is automatically set as the default format:

    ```crystal
    abstract class ApiAction < Lucky::Action
      accepted_formats [:json]
    end
    ```

    In an API action, requests would be handled like this:

    | URL | Accept Header | Server Response |
    | ----------- | ----------- | ----------- |
    | https://myapp.com/api/users | No specific request format | JSON (the default format) |
    | https://myapp.com/api/users | `Accept: application/json` | JSON (the requested, accepted format) |
    | https://myapp.com/api/users | `Accept: application/csv` | Response status 406 (not acceptable) |

    Browser actions, on the other hand, can support either JSON or HTML, and treat non-specified formats as HTML by default:

    ```crystal
    abstract class BrowserAction < Lucky::Action
      accepted_formats [:html, :json], default: :html
    end
    ```

    In a browser action, requests would be handled like this:

    - `https://myapp.com/users` with no specific request format => Server responds with HTML (the default format)
    - `https://myapp.com/users` with `Accept: application/json` => Server responds with JSON (the requested, accepted format)
    - `https://myapp.com/users` with `Accept: application/csv` => Server responds with 406 (not acceptable)

    It's important to note that this only controls which requests are *accepted* for processing, and does not automatically create or handle those responses appropriately. For example, requesting `https://myapp.com/users` with an `Accept: application/xml` header does not mean that valid XML content will be returned automatically, only that Lucky will allow your action to process the request.

    ## HTTP Headers

    ### Accessing Headers

    If you need to access or set the headers, you can use `request.headers` or `response.headers`.

    ```crystal
    class Dashboard::Index < BrowserAction
      get "/dashboard" do
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
      get "/admin/reports/:report_id" do
        response.headers["Cache-Control"] = "max-age=150"
        html ShowPage
      end
    end
    ```

    You can read more about working with headers in the [Crystal docs on HTTP::Headers](https://crystal-lang.org/api/HTTP/Headers.html).

    #{permalink(ANCHOR_HANDLING_RESPONSES)}
    ## Handling Responses

    Every action is required to return a response

    These are the built-in Lucky response methods:

    * `html` - render a Lucky::HTMLPage
    * `redirect` - redirect the request to another location
    * `plain_text` - respond with plain text with `text/plain` Content-Type.
    * `json` - return a JSON response with `application/json` Content-Type.
    * `raw_json` - similar to `json`. See [Rendering JSON](#{Guides::JsonAndApis::RenderingJson.path}) for comparisons.
    * `xml` - return an XML response with `text/xml` Content-Type.
    * `head` - return HTTP HEAD response
    * `file` - return a file for download
    * `data` - return a String of data
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

    #{permalink(ANCHOR_HTML_WITH_CUSTOM_STATUS)}
    ### HTML with non-200 status

    The `html()` macro will render your Page object with a 200 status.
    Error status codes like 404, 422, and 500, are handled separately
    by your `Errors::Show` action. Read the [Error Handling](#{Guides::HttpAndRouting::ErrorHandling.path})
    guide for more info.

    In cases where you want to render an HTML page, but with a custom
    status, Lucky provides a separate `html_with_status` macro.

    ```crystal
    get "/teaparty" do
      html_with_status IndexPage, 418
    end
    ```

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

    ### Rendering raw data

    If you need to return a file that already exists, you can use `file`, but in the case that you only have the
    String data, you can use this `data` method.

    ```crystal
    class Reports::Show < BrowserAction

      get "/reports/sales" do
        report_data = "Street,City,State\n123 street, Luckyville, CR\n"
        data report_data,
            disposition: "attachment",
            filename: "report-\#{Time.utc.month}.pdf",
            content_type: "application/csv"
      end
    end
    ```

    > The default `Content-Type` for `data` is `"application/octet-stream"`

    ### Rendering components

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

    Text responses are compressed automatically based on two `Lucky::Server.settings` entries. If alternate behavior is desired, these settings can be adjusted in your Lucky app in `config/server.cr`

    - `Lucky::Server.settings.gzip_enabled` (enabled in production by default, disabled in development and test. Can be changed in `config/server.cr`)
    - `Lucky::Server.settings.gzip_content_types`

    #{permalink(ANCHOR_REDIRECTING)}
    ## Redirecting

    You can redirect using the `redirect` method:

    > Note that for most methods that link you elsewhere (like `redirect`, or the
    `link` helper in HTML pages), you can pass the action directly if it does not
    need any params. You can see this in the first `redirect` example below.

    ```crystal
    class Users::Create < BrowserAction
      post "/users" do
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

    > The `fallback` argument is required and is used if the HTTP Referer is empty.

    For security, Lucky prevents the `redirect_back` from sending the user back to an external host. If you want to allow this, you'll need
    to set the `allow_external: true` option.

    ```crystal
    post "/newsletter/signup" do
      # Referer set to https://external.site/
      redirect_back fallback: Home::Index, allow_external: true
    end
    ```

    #{permalink(ANCHOR_RUN_CODE_BEFORE_OR_AFTER_ACTIONS_WITH_PIPES)}

    ## Custom Content Types

    Each of the response methods will have a built-in content type for that specific
    method. If you're using `html`, it'll return `text/html`. For JSON, it'll return `application/json`.
    When you need to change these values, there's a method for the specific type you can
    override.

    For html, you'll use the `html_content_type` method. For JSON, it's the `json_content_type`.
    There's also XML, and plain text available in `xml_content_type` and `plain_content_type`
    respectively.

    ```crystal
    class Logs::Index < BrowserAction
      get "/logs" do
        logs = LogQuery.new
        html IndexPage, logs: logs
      end

      def html_content_type
        "text/html; charset=ISO-8859-1"
      end
    end
    ```
    MD
  end
end
