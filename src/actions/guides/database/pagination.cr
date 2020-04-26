class Guides::Database::Pagination < GuideAction
  guide_route "/database/pagination"

  def self.title
    "Pagination"
  end

  def markdown : String
    <<-MD
    ## Introduction

    In many frameworks pagination can be painful. You may have multiple
    options to choose from, the HTML can be hard to customize, and often the
    APIs are hard to understand.

    In Lucky and Avram, we've built in pagination and HTML pagination
    components so you can get started quickly. You can also copy the HTML
    components to your app and customize them to your hearts content.

    Let's dive in!

    ## Setup

    You can paginate records from within an action by including the
    [`Lucky::Paginator::BackendHelpers`](https://github.com/luckyframework/lucky/blob/master/src/lucky/paginator/backend_helpers.cr)
    in your actions.

    It's usually best to include the helpers in your base actions, such as `ApiAction`
    or `BrowserAction`. That way any action that inherits from them has access to the included methods:

    ```crystal
    # src/actions/browser_action.cr
    abstract class BrowserAction < Lucky::Action
      include Lucky::Paginator::BackendHelpers
    end
    ```

    > We are using `BrowserAction` in this example, but it works the same for
    ApiAction > or any other `Lucky::Action`

    This module will add the `paginate` method to you actions. This is what
    you'll use to paginate your query results.

    ## Paginating

    Pagination is easy-peasy, call `paginate` with a query:

    ```crystal
    class Users::Index < BrowserAction
      get "/users" do
        pages, users = paginate(UserQuery.new)
        html IndexPages, users: users, pages: pages
      end
    end
    ```

    In this case `pages` is a `Lucky::Paginator` with metadata about the
    current page, total numbers of pages, and helpers for generating paths to
    next and previous pages.

    The other variable, `users`, is the passed in query (`UserQuery.new`)
    with a `limit` and `offset` applied so it returns records for just
    the requested page.

    `paginate` will use the `page` param or fallback to page `1` if `page` is
    not present. The `page` param can be a query param, a body param, or a
    route param.

    Next we'll go over how to customize the defaults.

    ## Customizing defaults

    By default `paginate` returns `25` records per page and uses the `page`
    param to determine which page is requested. But if you want something else,
    you can!

    ### Customizing records per page

    There are 2 ways to customize items per page.

    You can pass it to the `paginate` method:

    ```crystal
    paginate(UserQuery.new, per_page: 50)
    ```

    Or you can customize it with a method on your action:

    ```crystal
    abstract class BrowserAction < Lucky::Action
      include Lucky::Paginator::BackendHelpers

      def paginator_per_page : Int32
        50 # Return a static value

        # Or allow using a param with a default
        params.get?(:per_page).try(&.to_i) || 50
      end
    end
    ```

    As you can see you can customize this however you want. You can use a
    request headers, static value, param, or whatever custom logic you prefer.

    ### Customize current page

    By default `paginate` uses the `page` param. The param can come from a
    query param, route param, or body param. If the `page` param is not
    there, it will fall back to page `1`.

    If this logic is not what you want, you can customize it by creating
    a `paginator_page` that returns an `Int32`

    ```crystal
    abstract class ApiAction < Lucky::Action
      include Lucky::Paginator::BackendHelpers

      def paginator_page : Int32
        request.headers["Page"]?.try(&.to_i) || 1
      end
    end
    ```

    You can use headers, params, or whatever custom logic you'd like.

    ## HTML components

    With just 2 lines of code you can render pagination links in your HTML pages.

    * Add a `needs pages : Lucky::Paginator`
    * Mount one of the built-in pagination components

    ```crystal
    class Users::IndexPage < MainLayout
      needs users : UserQuery
      needs pages : Lucky::Paginator # Add this to use the paginator

      def render
        # Mount one of the built-in components
        mount Lucky::Paginator::SimpleNav.new(pages)
      end
    end
    ```

    ### Built-in components

    There are 3 bult-in components:

    * `Lucky::Paginator::SimpleNav` uses a `ul` and `li` tags and no classes for styling.
    * `Lucky::Paginator::BootstrapNav` uses Bootstrap pagination HTML and classes.
    * `Lucky::Paginator::BulmaNav` uses Bulma pagination HTML and classes.

    ### Customizing built-in components:

    The `SimpleNav` component will almost certainly need to be customized to
    fit your websites theme, but any of the components can be customized or
    used as an example for something you build from scratch.

    1. Create an empty component in your app, for example: `lucky gen.component PaginationLinks`
    1. Find the component you want to customize from the [Lucky repo's components directory](https://github.com/luckyframework/lucky/tree/master/src/lucky/paginator/components)
    1. Copy the contents of the component into your newly generated component

    And that's it! You can `mount` it like any other component `mount
    PaginationsLinks.new(page)` and customize the HTML and classes as much as
    you'd like.

    ## API responses

    The `Lucky::Paginator` object can help to add pagination metadata to JSON
    responses.

    ### Adding to response headers

    This is likely the best approach since you don't need to modify the JSON
    response at all.

    ```crystal
    class Api::Users::Index < ApiAction
      get "/api/users/index" do
        pages, users = paginate(UserQuery.new)
        reponse.headers["Next-Page"] = pages.path_to_next
        reponse.headers["Total-Pages"] = pages.total
        json UserSerializer.for_collection(users)
      end
    end
    ```

    We'll go into more details about all the methods on `Lucky::Paginator`
    later, but this simple example shows how you can use the paginator object
    to provide helpful pagination data in your API responses.

    ### A JSON example

    This is a simple example that returns some metadata as JSON.

    ```crystal
    class Api::Users::Index < ApiAction
      get "/api/users/index" do
        # We'll skip returning the users for this example
        pages, _users = paginate(UserQuery.new)
        json(next_page: pages.path_for_next, total_items: pages.item_count)
      end
    end
    ```

    ### Adding pagination data to all JSON collections

    Next, let's do something a bit more realistic. We'll modify the
    `BaseSerializer` to accept a `Lucky::Paginator` when rendering a
    collection. That way we can add pagination data to every JSON response that
    renders a collection.

    ```crystal
    # src/serializers/base_serializer.cr
    abstract class BaseSerializer < Lucky::Serializer
      # Add a new 'pages' argument
      def self.for_collection(collection : Enumerable, pages : Lucky::Paginator, *args, **named_args)
        {
          "items" => collection.map do |object|
            new(object, *args, **named_args)
          end,
          # Add pagination metadata to the response
          "pagination" => {
            next_page: pages.path_to_next,
            previous_page: pages.path_to_previous,
            total_items: pages.item_count,
            total_pages: pages.total
          }
        }
      end
    end
    ```

    If you want to customize rendering further, see the [collection rendering
    guide](#{Guides::JsonAndApis::RenderingJson.path(anchor: Guides::JsonAndApis::RenderingJson::ANCHOR_CUSTOMIZING_COLLECTION)}).

    Next, we'll go into details about all the methods available on the
    `Lucky::Paginator` object.

    ## Paginate arrays

    If you working with arrays that are not coming from the database you can use
    the `paginate_array` method. It will paginate the array and return the `Paginator`
    object for that array.

    ```crystal
      array = [1, 2, 3, 5, 6, 7]
      pages, numbers = paginate_array(array)
      html IndexPages, numbers: numbers, pages: pages
    ```

    The array can contain all different types, like `Int32`, `String`, or your
    own classes.

    ## The Lucky::Paginator object

    The `paginate` method returns a `Lucky::Paginator` object. This object
    contains information about the pages as well as a number of methods for
    generating paths to a given page.

    ### `page`

    The page method returns the requested page as an Int32

    ### `item_count`

    The total number of items in the query as an `Int32 | Int64`

    ### `one_page?`

    Returns `true` if there is just 1 page.

    ### `last_page?`

    Returns `true` if you are on the last page.

    ### `first_page?`

    Returns `true` if you are on the first page.

    ### `total`

    Returns the total number of pages as an `Int64`

    ### `overflowed?`

    Returns `true` if the requested page is past the last page.

    ### `path_to_next`

    Returns the path with a 'page' query param for the next page.

    Returns `nil` if there is no next page.

    ### `path_to_previous`

    Returns the path with a 'page' query param for the previous page.

    Returns `nil` if there is no previous page.

    ### `path_to_page`

    Returns the path with a 'page' query param for the given page.

    ### `item_range`

    Returns the `Range` of items on this requested page.

    For example if you have 50 records, showing 20 per page, and you are on
    the 2nd page this method will return a range of 21-40.

    You can get the beginning and end by calling `begin` or `end` on the
    returned `Range`.

    ```crystal
    range = pages.item_range
    "Showing #\{range.begin}-#\{range.end} of #\{pages.item_count}"
    ```

    ### `series`

    Requires its own section 😃

    ## The 'series' method

    The `series` method calculates the series of pages and gaps based on how
    many pages there are, and what the current page is. It uses the
    `begin|left_of_current|right_of_current|end` arguments to customize the
    returned series of pages and gaps. The series is made up of
    `Lucky::Paginator::Gap`, `Lucky::Paginator::Page` and
    `Lucky::Paginator::CurrentPage` objects. This method is typically used to
    build pagination links in HTML.

    ### An example

    **The best way to describe how this works is with an example.** Let's say
    you have 10 pages of items and you are requesting page 5.

    > Note we will simplify the objects by using integers and ".." in place of the
    > `Gap|Page|CurrentPage` objects. We'll show an example with the real
    objects further down

    ```crystal
    # 10 pages of items and you are requesting page 5
    series = pages.series(begin: 1, left_of_current: 1, right_of_current: 1, end: 1)
    series # [1, .., 4, 5, 6, .., 10]

    # All args default to 0 so you can leave them off. That means `begin|end`
    # are 0 in this example.
    series = pages.series(left_of_current: 1, right_of_current: 1)
    series # [4, 5, 6]

    # The current page is always shown
    series = pages.series(begin: 2, end: 2)
    series # [1, 2, .., 5, .., 9, 10]

    # The `series` method is smart and will not add gaps if there is no gap.
    # It will also not add items past the current page.
    series = pages.series(begin: 6)
    series # [1, 2, 3, 4, 5]
    ```

    As mentioned above the **actual** objects in the Array are made up of
    `Lucky::Paginator::Gap`, `Lucky::Paginator::Page`, and
    `Lucky::Paginator::CurrentPage` objects.

    ```crystal
    pages.series(begin: 1, end: 1)
    # Returns:
    # [
    #   Lucky::Paginator::Page(1),
    #   Lucky::Paginator::Gap,
    #   Lucky::Paginator::CurrentPage(5),
    #   Lucky::Paginator::Gap,
    #   Lucky::Paginator::Page(10),
    # ]
    ```

    The `Page` and `CurrentPage` objects have a `number` and `path` method.
    `Page#number` returns the number of the page as an Int. The `Page#path` method
    Return the path to the next page.

    The `Gap` object has no methods or instance variables. It is there to
    represent a "gap" of pages.

    These objects make it easy to use [method # overloading](https://crystal-lang.org/reference/syntax_and_semantics/overloading.html)
    or `is_a?` to determine how to render each item.

    ### Rendering the series

    Here's a quick example that prints strings:

    ``` crystal
    pages.series(begin: 1, end: 1).each do |item|
      case item
      when Lucky::Paginator::CurrentPage | Lucky::Paginator::Page
        pp! item.number # Int32 representing the page number
        pp! item.path   # "/items?page=2"
      when Lucky::Paginator::Gap
        puts "..."
      end
    end
    ```

    Or use method overloading. This will show an example using Lucky's HTML methods:

    ```crystal
    class PageNav < BaseComponent
      needs pages : Lucky::Paginator

      def render
        pages.series(begin: 1, end: 1).each do |item|
          page_item(item)
        end
      end

      def page_item(page : Lucky::Paginator::CurrentPage)
        # If it is the current page, just display text and no link
        text page.number
      end

      def page_item(page : Lucky::Paginator::CurrentPage)
        a page.number, href: page.path
      end

      def page_item(gap : Lucky::Paginator::Gap)
        text ".."
      end
    end
    ```

    See the [built-in SimpleNav
    component](https://github.com/luckyframework/lucky/blob/master/src/lucky/paginator/components/simple_nav.cr)
    to see `series` in action and get some ideas.
    MD
  end
end
