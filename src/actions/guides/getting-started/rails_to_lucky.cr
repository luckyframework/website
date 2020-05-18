class Guides::GettingStarted::RailsToLucky < GuideAction
  guide_route "/getting-started/rails-to-lucky"

  def self.title
    "Rails to Lucky"
  end

  def markdown : String
    <<-MD
    ## Introduction

    If you use Rails, this guide will make your transition to Lucky easier.
    This guide contains common rails terms and how they map to Lucky, along
    with cheatsheets and links to the relevant Lucky guides.

    ## File structure & naming conventions

    This covers the most common files and naming conventions. We'll go into
    more details in sections below.

    * `app` -> `src`
    * `lib` -> `src`. Typically you'd put your Rails `lib` files at the top-level of `src` in Lucky, e.g. `src/my_util.cr`
    * `Rakefile` -> `tasks.cr`
    * `Gemfile` -> `shard.yml`
    * `routes.rb` -> [routes defined in actions](#{Guides::HttpAndRouting::RoutingAndParams.path})
    * `app/assets/{javascripts|stylesheets}` -> `src/{css|js}`
    * `app/assets/images` -> `public/assets/images`
    * `app/controllers/application_controller`
      * `src/actions/{browser_action|api_action}.cr` - `BrowserAction < Lucky::Action`
    * `app/controllers/users_controller.rb`
      *`src/actions/users/{index|show|etc}.cr` - `Users::Index < BrowserAction`
    * `app/models/user.rb`
      * `src/models/user.cr` - `User < BaseModel`
      * `src/queries/user_query.cr` - `UserQuery < User::BaseQuery`
      * `src/operations/save_user.cr` - `SaveUser < User::SaveOperation`
    * `app/views/layouts/application.html.erb`
      * `src/pages/main_layout.cr` - `MainLayout`
    * `app/views/users/index.html.erb`
      * `src/pages/users/index_page.cr` - `Users::IndexPage < MainLayout`
    * `app/views/users/_my_partial.html.erb`
      * `src/components/users/my_component.cr` - `Users::MyComponent < BaseComponent`
    * `test/spec` -> same conventions `spec/type_of_test/test_name_spec.cr`

    ## General Crystal tips for Rubyists

    Here are some important differences and gotchas when switching from Ruby
    to Crystal.

    ### Hash and Array gotchas

    Reading and writing Arrays and Hashes is very similar in Crystal. However
    there is one very important caveat: `[]` and `first`, `last`, etc. will
    raise an exception if the key or index is empty.

    If you want to return `nil` for missing keys/indexes, use `[]?`, `first?`, `last?`, etc.

    ```crystal
    # This will raise if the key is missing and never reach the default value
    ENV["MY_VAR"] || "default value"

    # This is what you want:
    ENV["MY_VAR"]? || "default value"
    ```

    Also be careful with `if`:

    ```crystal
    # This will raise if "key" is not present
    if some_hash["key"]
      do_something_with(some_hash["key"])
    end

    # This is what you want:
    if some_hash["key"]?
      do_something_with(some_hash["key"])
    end
    ```

    ### Conditionals and working with `nil`

    ## Starting a new project

    * `rails new` -> `lucky init`
    * `rails new --api` -> `lucky init` has a wizard that let's you customize what options you want.
    * `rails s` -> `lucky dev` starts a server and any other processes defined in `Procfile.dev`

    Learn more in the [Starting a Project](#{Guides::GettingStarted::StartingProject.path}) guide.

    ## Controllers, routing, and url helpers

    * Instead of *Controllers*, Lucky has *Actions*.
    * Instead of a *routes file*, routes are defined *in the Action*.
    * Instead of route helpers like `users_path`, Lucky generates routes by calling methods on the Action, e.g. `Users::Index.path`

    ### Actions: organization and naming

    * Generate an action with `lucky gen.action.{browser|api} {ActionName}`
      * `lucky gen.action.browser Users::Index`
      * `lucky gen.action.api Api::Users::Index`
    * Actions are named like `{OptionalNamespace}::{PluralResource}::{Action}`
      * `Users::Index`
      * `Tasks::Archive`
      * `Admin::Users::Show`
      * However, they can be whatever you want: `FooBarAction`
    * Actions go in `src/actions/{optional_namespace}/{plural_resource}/{action}.cr`
      * `src/actions/users/index.cr`
      * `src/actions/api/users/index.cr`
    * Nested resource actions should not have the parent resource in the Action name.
      * `get "/projects/:project_id/tasks"` -> `Tasks::Index` (no parent resource in the Action name)

    Lucky will still work if you break the naming conventions, but it may be
    confusing since documentation and other Lucky users expect these
    conventions to be followed. If you use a different folder structure you
    may need to modify the `require` statements in `src/app.cr`

    Or stick with the conventions and don't worry about it 😎.

    ### Actions: responses

    * No implicit rendering.
      * Actions must explicitly render HTML, JSON, etc. or redirect.
    * Render HTML with `html`
      * Views do not have access to instance vars. Data must be passed explicitly.
      * `html Users::IndexPage, users: UserQuery.new, other_data: "value"`
    * Redirect with `redirect`
      * `redirect to: Users::Index` an Action with no params
      * `redirect to: Users::Show.with(user.id)` an Action that requires a user id.
      * `redirect to: "http://external.com"`
    * Render json with a `NamedTuple` or a `Lucky::Serializer`
      * `json({name: "Jane"})`
      * `json({name: "Jane"}, status: 201)`
      * `json UserSerializer.new(UserQuery.first)`
      * `json UserSerializer.for_collection(UserQuery.new)`
    * Head response with `head {status_code}`
      * `head 201`
      * `head HTTP::Status::CREATED`. See list of [HTTP Statuses](https://crystal-lang.org/api/0.34.0/HTTP/Status.html)

    Learn about other response methods:

    * [Requests and Responses](#{Guides::HttpAndRouting::RequestAndResponse.path})
    * [Rendering JSON](#{Guides::JsonAndApis::RenderingJson.path})

    ### Actions: flash

    * `flash.{info|success|failure} = "message"`
    * Or use any key you want with: `flash.set("my-special_key", "Super spesh")`
    * Customize flash rendering in `src/components/shared/flash_messages.cr`

    Learn more in the [Flash Messages](#{Guides::HttpAndRouting::Flash.path}) guide.

    ### Actions: requests

    * Determine the requested content type with:
      * `json?` - true if the client accepts "application/json"
      * `ajax?` - true if the X-Requested-With header is "XMLHttpRequest"
      * `html?` - true if the client accepts HTML
      * `xml?` - true if the client accepts "application/xml" or "application/xhtml+xml"
      * `plain?` - true if the client accepts "text/plain"
    * Set accepted content types:
      * `accepted_formats [:html, :json], default: :html`
    * Use `cookies` and `session` to manage cookies and sessions.
      * Cookies and the session are signed and encrypted by default.
      * They are http only by default so JavaScript cannot access them.
      * `session|cookies.set(:name, "Will")`
      * `session|cookies.get(:name)` This version raises an error if `name` is missing.
      * `session|cookies.get?(:name)` This version returns `nil` if missing.
    * Headers
      * `request.headers["Some-Header"]` or `request.headers["Some-Header"]?` (ending with `?`) if the header might be blank
      * `response.headers["Some-Header"] = "value"`

    Learn more:

    * [Sessions and Cookies guide](#{Guides::HttpAndRouting::SessionsAndCookies.path})

    ### Actions: params and routing

    * `root` -> `get "/"`
    * `get "*"` -> [`fallback`](#{Guides::HttpAndRouting::RoutingAndParams.path(anchor: Guides::HttpAndRouting::RoutingAndParams::ANCHOR_FALLBACK_ROUTING)})
    * `get|put|post|delete` etc.
      * For example: `get "/users"` or `delete "/users/:user_id"`
    * `resource(s)` -> Does not exist. Each route defines its path. In the future you will be able to enforce REST conventions.
    * `namespace` -> `route_prefix`

    ```crystal
    # Any action that inherits from ApiAction will be namespaced under "/api/v1"
    abstract class ApiAction < Lucky::Action
      route_prefix "/api/v1"
    end
    ```

    ### Route helpers

    Instead of generating special "helper methods" like `users_path`, Lucky
    uses a more direct that we think is easier to understand. It also
    automatically includes the correct HTTP method. This leads to far fewer errors
    where the path is correct, but the HTTP method is wrong.

    * `get "/users"`
      * `Users::Index` or `Users::Index.route`.
      * Most link helpers, `redirect`, and forms helpers can take a raw Action class
        that needs no params. Typically `.route` should not be used.
    * `get "/users/:user_id"`
      * `Users::Show.with(user.id)`
    * Can pass an optional anchor: `Users::Index.with(anchor: "my-anchor")`

    All these methods return a `Lucky::RouteHelper` object with a `path` and
    `method`. Most Lucky methods that work with Actions allow you to use these objects instead of plain strings.
    It will use the `path` and `method` to make sure the correct HTTP method is used.

    For example:

    * `redirect to: Users::Show.with(user.id)
    * `link "Users", Users::Index`
    * `link "Delete", Users::Delete.with(user.id)
    * `form_for Users::Create`

    ### Generating string paths

    You can `path`, `url` and `url_without_query_params` to get back
    a `String` instead of a `Lucky::RouteHelper`. This can be useful for
    generating callbacks, outputting a full URL in emails, etc.

    * `url`
      * `Users::Index.url` -> `"http://localhost:3001/users"`
      * `Users::Show.with(user.id)` -> `"http://localhost:3001/users/123"`
    * `path`
      * `Tasks::Show.path(project.id, user.id)` -> `"/projects/123/tasks/456"`
    * `url_without_query_params`
      * Allows generating a URL without query params
      * Particularly useful for generating callback URLs.

    ```crystal
    class OAuth::Create < BrowserAction
      # The OAuth callback should always return a 'code' query param
      # But the 'code' param is not needed when generating the URL...
      param code : String
    end

    # Use url_without_query_params to skip passing the 'code'
    OAuth::Create.url_without_query_params # "http://localhost:3001/oauth/callback"
    ```

    ### Example Action

    `lucky gen.action.browser Tasks::Index` will create a `Tasks::Index` action in `src/actions/tasks/index.cr`

    Here is a modified `Tasks::Index` with a number of common Lucky features:

    ```crystal
    # Actions usually inherit from BrowserAction, or ApiAction
    class Tasks::Index < BrowserAction
      # Similar to 'before_action'
      before :require_awesome_user

      # This action accepts a 'hide_completed' query param
      param hide_completed : Bool = true

      # Define the route
      get "/projects/:project_id/tasks" do
        # Lucky creates 'project_id' method that returns the
        # `:project_id` section of the path.
        tasks = TaskQuery.new.project_id(project_id)

        # Use 'hide_completed' to scope the query
        if hide_completed
          # Only return tasks with 'false' in the 'complete' column
          tasks = tasks.complete(false)
        end

        # You tell Lucky what page to render and pass it data (no instance vars)
        html Tasks::IndexPage, tasks: tasks
      end

      def require_awesome_user
        # All our users are awesome
        if current_user
          # Unlike Rails, you must explicitly 'continue' or render/redirect.
          continue
        else
          flash.info = "Please sign in first so we can verify awesomeness."
          redirect to: SignIns::New
        end
      end
    end
    ```
    MD
  end
end
