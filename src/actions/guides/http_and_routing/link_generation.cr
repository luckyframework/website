class Guides::HttpAndRouting::LinkGeneration < GuideAction
  guide_route "/http-and-routing/link-generation"

  def self.title
    "URL and Link Generation"
  end

  def markdown : String
    <<-MD
    ## Path and route helpers

    Lucky automatically generates some helpers for generating links.

    You can access them as class methods on the action itself. They are:

    * `route` - will return a `Lucky::RouteHelper` object that contains both the
      path, the HTTP method, and the full URL as methods `path`, `method`, `url`
    * `with` - an alias for `route` that is used for passing parameters
    * `path` - will return a string of just the path
    * `url` - will return a string with the whole URL including query params
    * `url_without_query_params` - will return the URL but without query params

    ```crystal
    class Projects::Users::Index < BrowserAction
      # Normally you would use `nested_route`
      # We'll use `get` here to make the example more clear
      get "projects/:project_id/users" do
        plain_text "Users"
      end
    end
    ```

    You can then call these methods:

    * `Projects::Users::Index.path(project_id: "my_project_id")` and it will return ->
      `"/projects/my_project_id/users"`
    * `Projects::Users::Index.with(project_id: "my_project_id")` and it will return a
      `LuckyWeb::RouteHelper` whose `#path` method returns
      `"/projects/my_project_id/users"` and `#method` method return `"GET"`. This
      is what you'll usually use for generating links, submitting forms, and redirecting.

    We'll talk about this more in the [Pages guide](#{Guides::Frontend::RenderingHtml.path}). You can use the route helper with
    links and forms to automatically set the path *and* HTTP method at the same time.
    MD
  end
end
