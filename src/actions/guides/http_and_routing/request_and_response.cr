class Guides::HttpAndRouting::RequestAndResponse < GuideAction
  guide_route "/http-and-routing/request-and-response"

  def self.title
    "Requests and Responses"
  end

  def markdown
    <<-MD
    ## Handling Requests

    When a request comes in to an Action, Lucky gives you access to the request object through the `request` method.
    > The `request` object is an instance of [HTTP::Request](https://crystal-lang.org/api/HTTP/Request.html).

    Lucky gives you access to a few helpful methods based on the request Content-Type.

    * `json?` - true if the Content-Type header is "application/json"
    * `ajax?` - true if the X-Requested-With header is "XMLHttpRequest"
    * `html?` - true if the Content-Type header is "text/html"
    * `xml?` - true if the Content-Type header is "application/xml" or "application/xhtml+xml"
    * `plain?` - true if the Content-Type header is "text/plain"

    You can use these methods to help direct the request or return different responses.

    ```crystal
    class Users::Show < BrowserAction
      route do
        if json?
          # The Content-Type is a json request, so let's return some json
          json(Users::ShowSerializer.new(current_user))
        else
          # Just render the page like normal
          render Users::ShowPage
        end
      end
    end
    ```

    ## Handling Responses

    Once you've recieved your request, and handled it, you'll need to return a response. Every Lucky::Action requires that a response is returned.

    * `render` - render a Lucky::HTMLPage
    * `redirect` - redirect the request to another location
    * `text` - respond with plain text
    * `json` - return a json response
    * `head` - return a head response with a 204 status
    * `file` - return a file for download

    ## Redirecting

    You can redirect using the `redirect` method:

    > Note that for most methods that link you elsewhere (like `redirect`, or the
    `link` helper in HTML pages) you can pass the action directly if it does not
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

    The default status for a redirect is `Lucky::Action::Status::Found` (302), but if you need a different status code, you can pass any [Lucky Action Status Enum](https://github.com/luckyframework/lucky/blob/v0.14.0/src/lucky/action.cr#L20)




    MD
  end
end
