class Guides::HttpAndRouting::RoutingAndParams < GuideAction
  ANCHOR_AUTOMATICALLY_GENERATE_RESTFUL_ROUTES = "perma-automatically-generate-restful-routes"
  ANCHOR_FALLBACK_ROUTING                      = "perma-fallback-routing"
  guide_route "/http-and-routing/routing-and-params"

  def self.title
    "Routing and Params"
  end

  def markdown : String
    <<-MD
    > Check out ["Designing Lucky: Rock Solid Actions &
    Routing"](https://robots.thoughtbot.com/designing-lucky-actions-routing) to
    see how Lucky can make writing your applications reliable and productive
    with its unique approach to HTTP and routing.

    ## Routing

    Instead of having separate definition files for routes and controllers, Lucky combines them in action classes.
    This allows for solid error detection, and method and helper creation.

    To save some typing, Lucky can automatically infer a default route path from the name of the action class,
    if the name ends with a known [RESTful action (see below)](##{ANCHOR_AUTOMATICALLY_GENERATE_RESTFUL_ROUTES}).

    ### Example without route inference

    To see what a simple action looks like, let's generate an index action for showing users with
    `lucky gen.action.browser Users::Index`.

    ```crystal
    # src/actions/users/index.cr
    class Users::Index < BrowserAction
      get "/users/:user_id" do
        # `plain_text` sends plain/text to the client
        plain_text "Rendering something in Users::Index"
      end
    end
    ```

    Routes can be defined for specific request types by using the `get`, `put`, `post`, `patch`, `trace`, and `delete` macros.

    If you still need access to different methods like `options`, you can use the `match` macro.

    ```crystal
    # src/actions/profile/show.cr
    class Profile::Show < BrowserAction
      # Respond to an `HTTP OPTIONS` request
      match :options, "/profile" do
        # action code here
      end
    end
    ```

    > Note that `lucky gen.action.browser` is used to create actions that should be
    shown in a browser. Whereas `lucky gen.action.api` is used for actions meant
    to be used for an API (e.g. JSON).

    ### Root page

    By default Lucky generates a `Home::Index` action that handles the root path `"/"`.
    This is the action that renders the Lucky welcome page when you first run `lucky dev`.

    Change `Home::Index` to redirect to whatever action you want:

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
          html Lucky::WelcomePage
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

    When defining an explicit path, you may mark parts of the path with a `:`,
    to have a method generated that returns that param in the action.

    ```crystal
    # src/actions/users/show.cr
    class Users::Show < BrowserAction
      get "/users/:some_user_id" do
        plain_text "Requested user id: \#{some_user_id}"
      end
    end
    ```

    Here, the string from the request path will be returned by the `some_user_id` method.
    So in this example if `/users/123-foo` is requested `some_user_id` would return `123-foo`,
    and the action would return a text response of `Requested user id: 123-foo`.

    ### You can use as many parameters as you want

    Every named parameter will have a method generated for it so that you can
    access the value. You can have as many as you want.

    For example, `delete "/projects/:project_id/tasks/:task_id"` would have a
    `project_id` and `task_id` method generated on the class for accessing the named
    parameters.

    #{permalink(ANCHOR_AUTOMATICALLY_GENERATE_RESTFUL_ROUTES)}
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

    [The macros `route` and `nested_route` do still exist, and automatically imply the default route paths,
    however, their deprecation is [discussed](https://github.com/luckyframework/lucky/issues/789). Moving
    the automatic path inference to the generators will make the actions more concrete and directly readable.]

    The `route` macro uses the first part of the class name as the resource name,
    and the second part as one of the resourceful actions listed above.

    ```crystal
     class Users::Show < BrowserAction
     # From the name,
     #   "Users" is the resource, and
     #   "Show" is the RESTful action.

      route do   # The infered route is:  get "/users/:user_id"
        plain_text "A request was made for the user_id: \#{user_id}"
      end
    end
    ```

    > Routes that require an "id" param will be prefixed with the resource name like `user_id`. (e.g. `Users::Show` generates `user_id`, and `Projects::Show` generates `project_id`)

    ### `nested_route`

    For a nested resource it will use the third to last part as the
    nested resource name, the second to last part of the class name as the resource
    name,  and the last part as one of the resourceful actions listed above.

    ```crystal
    class Projects::Users::Index < BrowserAction
      # From the name,
      #   "Projects" is the parent resource
      #   "Users" is the nested resource
      #   "Index" is the RESTful action

      nested_route do  # The infered route is: get "/projects/:project_id/users"
        plain_text "Render list of users in project \#{project_id}"
      end
    end
    ```

    > Likewise, defining `Projects::Users::Show` would generate both `project_id` and `user_id`.


    ### Namespaces are handled automatically

    You can namespace your routes by prefixing the class name, e.g. with `Admin::`.

    ```crystal
    # in src/actions/admin/projects/index.cr
    class Admin::Projects::Index < BrowserAction
      # From the name,
      # anything before the resource (`Projects`) will be used as a namespace (`Admin`).

      route do   # The infered route is: get "/admin/projects"
        plain_text "Render list of projects"
      end
    end
    ```

    > Note the use of `route` here and not `nested_route`. These change how the routes are generated.

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

    #{permalink(ANCHOR_FALLBACK_ROUTING)}
    ## Fallback routing

    For some apps you may want a wildcard/catch-all behavior instead of rendering
    some HTML when Lucky can't find a route. For example, this type of behavior
    can be useful for Single Page Applications (SPAs) so that you can handle
    routing client-side.

    To do this, use the `fallback` macro.

    ```crystal
    # in src/actions/frontend/index.cr
    class Frontend::Index < BrowserAction
      fallback do
        if html?
          render Home::IndexPage
        else
          raise Lucky::RouteNotFoundError.new(context)
        end
      end
    end
    ```

    > The `fallback` should always contain a `Lucky::RouteNotFoundError`
    error. This is to throw a 404 when an asset, or some other file is not
    found.

    ## Memoization

    As your application gets larger, you may need to write helper methods that run expensive
    calculations, or queries. Calling these methods multiple times can lead to performance issues.
    To mitigate these, you can use the `memoize` macro.

    ```crystal
    class Reports::Show < BrowserAction
      get "/report" do
        small_number = calculate_numbers
        big_number = calculate_numbers + 1000
        render ShowPage, small_number: small_number, big_number: big_number
      end

      memoize def calculate_numbers : Int64
        # This is ran only the first time it's called
        ReportQuery.new.fetch_numbers_for_today(Time.utc)
      end
    end
    ```

    There are a few caveats to the `memoize` macro. It will not memoize `false`, or `nil` return values.
    If your method returns a "falsey" value, then it will be ran each time. Another thing to note is
    you can't memoize a method that takes an argument. This is due to the dynamic nature of the
    arguments.

    [Learn more about memoization](https://en.wikipedia.org/wiki/Memoization).

    ## 404 errors

    By default Lucky will respond with a 404 when neither a route nor a static
    file in public is found. You can change what is rendered in `Errors::Show` which
    is found in `src/actions/errors/show.cr`.

    You'll see a method like this that handles when a route is not found:

    ```crystal
    # in src/actions/errors/show.cr
    #
    # Customize this however you want!
    def render(error : Lucky::RouteNotFoundError)
      if json?
        error_json "Not found", status: 404
      else
        error_html "Sorry, we couldn't find that page", status: 404
      end
    end
    ```

    > Learn more about [error handling](#{Guides::HttpAndRouting::ErrorHandling.path}).

    ## Query parameters

    Other times you may want to accept parameters in the query string, e.g. `https://example.com?page=2`.

    ```crystal
    # src/actions/users/index.cr
    class Users::Index < BrowserAction
      param page : Int32 = 1

      route do
        plain_text "All users starting on page \#{page}"
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

    For example `Users::Show` would go in `src/actions/users/show.cr` and `Api::V1::Users::Delete` would go in `src/actions/api/v1/users/delete.cr`.
    MD
  end
end
