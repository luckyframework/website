class Guides::HttpAndRouting::LinkGeneration < GuideAction
  guide_route "/http-and-routing/link-generation"

  def self.title
    "URL and Link Generation"
  end

  def markdown : String
    <<-MD
    ## Path and route helpers

    Lucky automatically generates some helpers for generating routes to your actions.

    You can access them as class methods on the action itself. They are:

    * `route` - returns a `Lucky::RouteHelper` object that contains the path, HTTP method,
      and the full URL as methods `path`, `method`, `url`.
    * `with` - an alias for `route` that is used for passing parameters.
    * `path` - returns a string of just the path.
    * `url_without_query_params` - returns a string of just path but without query
       params requried.
    * `url` - returns a string with the whole URL including query params.
    * `url_without_query_params` - will return the URL but without query params.

     ```crystal
    class SomeAction < BrowserAction
      param page : Int32

      get "/path" do
        plain_text "ok"
      end
    end

    # This will raise because `page` is required
    SomeAction.path

    SomeAction.path_without_query_params # => "/path"
    ```

    ```crystal
    # src/actions/projects/users/index.cr
    class Projects::Users::Index < BrowserAction

      get "/projects/:project_id/users" do
        plain_text "Users"
      end
    end
    ```

    From your pages or components, you can use these with the `link` method:

    ```crystal
    class Projects::Users::ShowPage < MainLayout

      def content
        # <a href="/projects/my_project_id/users">Back to Users Index</a>
        link "Back to Users Index",
          to: Projects::Users::Index.with(project_id: "my_project_id")
      end
    end
    ```

    The route `Projects::Users::Index.with(project_id: "my_project_id")` returns a `Lucky::RouteHelper`
    object that gives you access to a few methods:

    * `path` - `"/projects/my_project_id/users"`
    * `url` - `"http://example.com/projects/my_project_id/users"`
    * `method` - `"get"`

    These values are based on the action class this route points to.

    Learn more about using the routes in the [Pages guide](#{Guides::Frontend::RenderingHtml.path}).

    ### Setting an anchor

    In a web page, an anchor is a an element you can use to take a user to a specific part of a page.
    For example, we use this to link to different parts of a guide page.

    The `with` method takes an `anchor` argument.

    ```crystal
    def content
      # href="/guides/making-tacos#cheeses"
      link "See Section 2 of the guide",
        to: Guides::Show.with(id: "making-tacos", anchor: "cheeses")
    end
    ```

    ### Using raw strings

    If you need to pass arbitrary query params, or just need the path as a string,
    you can use the `path` or `url` methods directly. Note that `link` doesn't take a `String`,
    so you would need to use the `a()` HTML helper method directly.

    ```crystal
    def content
      a "Search again", href: Search::Index.path + "?a=1&b=2"
    end
    ```
    MD
  end
end
