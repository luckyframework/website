class Guides::HttpAndRouting::RequestAndResponse < GuideAction
  ANCHOR_RUN_CODE_BEFORE_OR_AFTER_ACTIONS_WITH_PIPES = "perma-run-code-before-or-after-actions-with-pipes"
  guide_route "/http-and-routing/request-and-response"

  def self.title
    "Requests and Responses"
  end

  def markdown
    <<-MD
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

    #{permalink(ANCHOR_RUN_CODE_BEFORE_OR_AFTER_ACTIONS_WITH_PIPES)}
    MD
  end
end
