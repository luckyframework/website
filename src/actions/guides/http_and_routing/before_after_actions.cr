class Guides::HttpAndRouting::BeforeAfterActions < GuideAction
  guide_route "/http-and-routing/before-after-actions"

  def self.title
    "Before / After Actions"
  end

  def markdown
    <<-MD
    ## Creating pipes

    Sometimes you want to run some code before or after an action is
    executed. In Lucky, we call these pipes. There is the `before` pipe and
    `after` pipe macros.

    ```crystal
    class Admin::Users::Index < BrowserAction
      before require_admin

      get "/admin/users" do
        plain_text "List of users"
      end

      private def require_admin
        if current_user.admin?
          continue
        else
          redirect to: SignIns::New
        end
      end

      private def current_user
        # Get the currently signed in user somehow
      end
    end
    ```

    Pipes *must* return `continue` or a standard
    [`Lucky::Response`](#{Guides::HttpAndRouting::RequestAndResponse.path(anchor: Guides::HttpAndRouting::RequestAndResponse::ANCHOR_HANDLING_RESPONSES)}).
    If a `Lucky::Response` is returned by rendering or redirecting, then no
    other pipe will run.

    > If your `before` pipe returns with a render or redirect, then the
    > action will not be called

    ## Sharing pipes across actions

    Sharing code between actions will be pretty common. Whether it's for
    authenticating, authorization, or just some logging, it's recommended to
    place these common methods in to a module that can be included in to the
    actions that need them.

    ```crystal
    # src/actions/mixins/log_request.cr
    module LogRequest
      macro included
        after log_request_path
      end

      private def log_request_path
        Lucky.logger.info({method: request.method, path: request.path})
      end
    end
    ```

    With our mixin defined, we can include it in to each action that requires it.

    ```crystal
    class Dashboard::Show < BrowserAction
      include LogRequest

      get "/dashboard" do
        plain_text "The dashboard"
      end
    end
    ```

    You could also include this in a base class like the built-in `BrowserAction`
    or `ApiAction` so all actions that inherit those will run the pipes.

    You could also create a new base action using an an [abstract class](https://crystal-lang.org/reference/syntax_and_semantics/virtual_and_abstract_types.html)
    like we do with the built-in ones. For example you could have an
    `AdminAction` that inherits from `BrowserAction` and includes your
    authorization based pipes. Then all admin actions can inherit from
    `AdminAction` and the authorization based pipes will be run.

    ## Skipping a pipe

    Sometimes you'll have a pipe in an abstract base class that you want to
    skip for certain actions. In those cases you can use the `skip` macro.

    Let's say we log the request in our `BrowserAction`. That means all actions
    that inherit from it will log the request.

    ```crystal
    class BrowserAction < Lucky::Action
      after log_request_path

      def log_request_path
        Lucky.logger.info({method: request.method, path: request.path})
      end
    end
    ```

    But if we want to skip this in one of our actions, we can with `skip`.

    ```crystal
    class Users::Index < BrowserAction
      skip log_request_path
    end
    ```
    MD
  end
end
