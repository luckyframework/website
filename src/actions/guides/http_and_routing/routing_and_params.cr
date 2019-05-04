class Guides::HttpAndRouting::RoutingAndParams < GuideAction
  guide_route "/http-and-routing/routing-and-params"

  def self.title
    "Routing and Params"
  end

  def markdown
    <<-MD
    > Check out ["Designing Lucky: Rock Solid Actions &
    Routing"](https://robots.thoughtbot.com/designing-lucky-actions-routing) to
    see how Lucky can make writing your applications reliable and productive
    with its unique approach to HTTP and routing.

    ## Routing

    Unlike many frameworks, there is no separate routes file. An action declares
    which route it handles in the class itself.

    You can route to an action by using `get`, `put`, `post`, `patch`, `trace`, and `delete` macros, or
    [Lucky can figure it out for you](#automatically-generate-restful-routes).

    If you need access to a different method like `options`, you can also use the `match` macro.

    ```crystal
    # src/actions/profile/show.cr
    class Profile::Show < BrowserAction
      # Will respond to an `HTTP OPTIONS` request.
      match :options, "/profile" do
        # action code here
      end
    end
    ```

    Let's generate an index action for showing users with `lucky
    gen.action.browser Users::Index` to see what a simple action looks like:

    ```crystal
    # src/actions/users/index.cr
    class Users::Index < BrowserAction
      # GET requests to the /users path are handled by this action
      get "/users" do
        # `text` sends plain/text to the client
        text "List of users goes here"
      end
    end
    ```

    > Note `lucky gen.action.browser` is used to create actions that should be
    shown in a browser. You can also use `lucky gen.action.api` for actions meant
    to be used for a JSON API.

    ### Root page

    By default Lucky generates a `Home::Index` action that handles the root path `"/"`.
    This is the action that shows you the Lucky welcome page when you first run `lucky dev`.

    Change `Home::Index` to redirect the user to whatever action you want:

    ```crystal
    # src/actions/home/index.cr
    class Home::Index < BrowserAction
      include Auth::SkipRequireSignIn

      get "/" do
        if current_user?
          # By default signed in users go to the profile page
          # You can redirect them somewhere else if you prefer
          redirect Me::Show
        else
          # Change this to redirect to a different page when not signed in
          render Lucky::WelcomePage
        end
      end
    end
    ```

    > It may seem strange to redirect as soon as the users visits "/", but it comes
    in handy later on. It makes it easy to redirect to different places depending on
    who the user is. For example, if a user is an admin you may want to redirect
    them to the `Admin::Dashboard::Show` action, and if they're a regular user you
    may want to take them to the regular dashboard at `Dashboard::Show`.

    ### Path parameters

    Sometimes you want to name certain parts of the path and access them as parameters.

    ```crystal
    # src/actions/users/show.cr
    class Users::Show < BrowserAction
      get "/users/:my_user_id" do
        text "User with an id of \#{my_user_id}"
      end
    end
    ```

    When you start a section of the path with `:` it will generate method for
    that param in your action.

    In this case anything you pass in the part of the URL for `:my_user_id` will
    be available in the `my_user_id` method. So in this example if you visited
    `/users/123` then the `my_user_id` would return a text response of `User with
    an id of 123`.

    ### You can use as many parameters as you want

    Every named parameter will have a method generated for it that so that you can
    access the value. You can have as many as you want.

    For example, `delete "/projects/:project_id/tasks/:task_id"` would have a
    `project_id` and `task_id` method generated on the class for accessing the named
    parameters.

    ## Automatically generate RESTful routes

    REST is a way to make access to resources more uniform. It consists of the following actions:

    * `Index` - show a list of resources
    * `Show` - show one instance of a resource
    * `New` - typically used to render a form to create a resource
    * `Create` - create a resource. Usually means saving data to the database
    * `Edit` - typically used to render a form to edit an existing resource
    * `Update` - update an existing resource
    * `Delete` - delete the resource

    Use the `route` and `nested_route` macros to generate RESTful routes
    automatically based on the class name.

    ### `route`

    For `route`, it will use the first part of the class name as the resource name,
    and the second part as one of the resourceful actions listed above.

    ```crystal
    # Users is the resource
    # Show is the RESTful action
    class Users::Show < BrowserAction
      # Same as:
      #   get "/users/:user_id"
      route do
        text "The user with id of \#{user_id}"
      end
    end
    ```

    ### `nested_route`

    For a nested resource it will use the third to last part as the
    nested resource name, the second to last part of the class name as the resource
    name,  and the last part as one of the resourceful actions listed above.

    ```crystal
    # Projects is the parent resource
    # Users is the nested resource
    # Index is the RESTful action
    class Projects::Users::Index < BrowserAction
      # Same as:
      #   get "/projects/:project_id/users"
      nested_route do
        text "Render list of users in project \#{project_id}"
      end
    end
    ```

    ### Namespaces are handled automatically

    ```crystal
    # Anything before the resource (in this case, `Projects`) will be treated as a namespace
    class Admin::Projects::Index < BrowserAction
      # Same as:
      #   get "/admin/projects"
      route do
        text "Render list of projects"
      end
    end
    ```

    ### Examples of automatically generated routes

    For the `route` macro:

    *  `Users::Index`  -> `get "/users"`
    *  `Users::Show`  -> `get "/users/:user_id"`
    *  `Users::New`  -> `get "/users/new"`
    *  `Users::Create`  -> `post "/users"`
    *  `Users::Edit`  -> `get "/users/:user_id/edit"`
    *  `Users::Update`  -> `put "/users/:user_id"`
    *  `Users::Delete`  -> `delete "/users/:user_id"`
    * Multiple namespaces: `Api::V1::Users::Show`  -> `get "/api/v1/users/:user_id"`
    * Multi-word namespace: `MyAdminSection::Users::Show`  -> `get "/my_admin_section/users/:user_id"`

    For the `nested_route` macro:

    *  `Projects::Users::Index`  -> `get "/projects/:project_id/users"`
    *  `Projects::Users::Show`  -> `get "/projects/:project_id/users/:user_id"`
    *  `Projects::Users::New`  -> `get "/projects/:project_id/users/new"`
    *  `Projects::Users::Create`  -> `post "/projects/:project_id/users"`
    *  `Projects::Users::Edit`  -> `get "/projects/:project_id/users/:user_id/edit"`
    *  `Projects::Users::Update`  -> `put "/projects/:project_id/users/:user_id"`
    *  `Projects::Users::Delete`  -> `delete "/projects/:project_id/users/:user_id"`
    * Multiple namespaces: `Api::V1::Projects::Users::Show`  -> `get "/api/v1/projects/:project_id/users/:user_id"`
    * Multi-word namespace: `MyAdminSection::Projects::Users::Show`  -> `get "/my_admin_section/projects/:project_id/users/:user_id"`

    ## Catch-all and 404 errors

    By default Lucky will respond with a 404 when neither a route nor a static
    file in public is found. You can change what is rendered in `Errors::Show` which
    is found in `src/actions/errors/show.cr`.

    You'll see a method like this that handles when a route is not found:

    ```crystal
    # in src/actions/errors/show.cr
    #
    # Customize this however you want!
    def handle_error(error : Lucky::RouteNotFoundError)
      if json?
        json Errors::ShowSerializer.new("Not found"), status: 404
      else
        render_error_page title: "Sorry, we couldn't find that page.", status: 404
      end
    end
    ```

    For some apps you may want a wildcard/catch-all behavior instead of rendering
    some HTML when Lucky can't find a route. For example, this type of behavior
    can be useful for Single Page Applications (SPAs) so that you can handle
    routing client-side.

    ```crystal
    # in src/actions/errors/show.cr
    def handle_error(error : Lucky::RouteNotFoundError)
      if json?
        json Errors::ShowSerializer.new("Not found"), status: 404
      else
        # Render a page that loads your SPA app
        render CatchallPage
      end
    end
    ```

    > Learn more about [error handling and logging](/guides/logging-and-error-handling).

    ## Query parameters

    Other times you may want to accept parameters in the query string, e.g. `https://example.com?page=2`.

    ```crystal
    # src/actions/users/index.cr
    class Users::Index < BrowserAction
      param page : Int32 = 1

      route do
        text "All users starting on page \#{page}"
      end
    end
    ```

    When you add a query parameter with the `param` macro, it will generate a method for you to access the value.
    The parameter definition will inspect the given type declaration, so you can easily define
    required or optional parameters by using non- or nilable types (`Int32` vs. `Int32?`).
    Parameter defaults are set by assigning a value in the parameter definition. Query parameters
    are type-safe as well, so when `https://example.com?page=unlucky` is accessed with the above definition, an exception
    is raised.

    Just like path parameters, you can define as many query parameters as you want. Every
    query parameter will have a method generated for it to access the value.

    ## Where to put actions

    Actions go in `src/actions` and follow the structure of the class.

    For example `Users::Show` would go in `src/actions/users/show.cr` and `Api::V1::Users::Delete` would go in `src/actions/api/v1/users/delete.cr`roductive with its unique approach to actions and routing.
    MD
  end
end
