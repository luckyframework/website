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

    ## Starting a new project

    * `rails new` -> `lucky init`
    * `rails new --api` -> `lucky init` has a wizard that let's you customize what options you want.
    * `rails s` -> `lucky dev` starts a server and any other processes defined in `Procfile.dev`

    Learn more in the [Starting a Project](#{Guides::GettingStarted::StartingProject.path}) guide.

    ## Controllers, routing, and url helpers

    * Instead of "Controllers", Lucky has "Actions"
    * Instead of a "routes" file, routes are defined in the Action.
    * Instead of route helpers like `users_path`, Lucky generates routes by calling methods on the Action.

    ### Example Action

    `lucky gen.action.browser Tasks::Index` will create a `Tasks::Index` action in `src/actions/tasks/index.cr`

    Here's how a `Tasks::Index` action might look like when using various Lucky features:

    ```crystal
    # Class inherits from BrowserAction|ApiAction instead of ApplicationController
    class Users::Show < BrowserAction
      # These work similarly to Rail's 'before_action'
      before :require_awesome_user

      # Query params you want to use are explicitly defined
      #
      # Add a required query param
      param sort : String

      # Or add an optional query param
      param unused : String?

      # Define the route in the action
      get "/projects/:project_id/tasks" do
        # :project_id in the path creates a 'project_id' method.
        # You can call this get the 'project_id' from the path.
        tasks = TaskQuery.new.project_id(project_id)

        # Rendering is explicit in Lucky.
        # You tell Lucky what page to render and pass it data (no instance vars)
        html Tasks::IndexPage, tasks: tasks
      end

      def require_awesome_user
        if current_user # All our users are awesome
          # Unlike Rails, you must explicitly render, redirect or return 'continue'.
          # This helps make it clear what the pipe is doing and why.
          continue
        else
          flash.info = "Please sign in first so we can verify awesomeness."
          redirect to: SignIns::New
        end
      end
    end
    ```

    ### Routing Cheatsheet

    * `root` -> `get "/"`
    * `get "*"` -> [`fallback`](#{Guides::HttpAndRouting::RoutingAndParams.path(anchor: Guides::HttpAndRouting::RoutingAndParams::ANCHOR_FALLBACK_ROUTING)})
    * `get|put|post|delete` etc. -> `get|put|post|delete`
      * For example: `get "/users"` or `delete "/users/:user_id"`
    * `resource(s)` -> Does not exist. Each route defines its path. In the future you will be able to enforce REST conventions.
    * `namespace` -> `route_prefix`
      ```crystal
      # Any action that inherits from ApiAction will be namespaced under "/api/v1"
      abstract class ApiAction < Lucky::Action
        route_prefix "/api/v1"
      end
      ```

    ### Link generation cheatsheet

    Instead of generating special "helper methods" like "users_path", Lucky
    uses a more direct and easy to understand approach. It also automatically
    includes the correct HTTP method for fewer errors and eliminates the need
    to constantly be thinking about HTTP methods.

    * Users index: `users_path` -> `Users::Index`. Most link helpers, redirect,
      forms helpers can take a raw action class that needs no params. You can
      also do `Users::Index.route`
    * Users show: `user_path(user.id)` -> `Users::Show.with(user.id)`
    * Users delete: `user_path(user.id)` (and remember to add `method: :delete`) -> `Users::Delete.with(user.id)`

    All these methods return a `Lucky::RouteHelper` object with a `path` and
    `http_method` that redirects and HTML helpers use to set the correct path
    and HTTP method.

    You can also use `path`, `url` and `url_without_query_params` to get back
    a `String`. This can be useful for generating callbacks, outputting a
    full URL in emails, etc.

    * `get "/users"`: `Users::Index.url` -> `"http://localhost:3001/users"`
    * `get "/users/:user_id`: `Users::Show.url(user.id)` -> `"http://localhost:3001/users/123"`
    * `get "/projects/:project_id/tasks/:task_id`: `Tasks::Show.path(project.id, user.id)` -> `"/projects/123/tasks/456"`
    * `OAuth::Create.url_without_query_params`
      ```crystal
      class OAuth::Create < BrowserAction
        # Define a required query param
        param code : String

        get "/oauth/callback" do
          # ...
        end
      end
      ```
      * `OAuth::Create.url_without_query_params` will let you generate a URL without providing the query param.
      * Particularly useful for callback URLs
    MD
  end
end
