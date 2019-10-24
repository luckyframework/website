class Guides::GettingStarted::WhyLucky < GuideAction
  guide_route "/getting-started/why-lucky"

  def self.title
    "Why use Lucky?"
  end

  def markdown : String
    <<-MD
    ## The Lucky philosophy

    Lucky was designed to solve a few core problems that teams often see. Lucky strives to:

    * Catch bugs at compile time, rather than finding them in production.
    * Spend less time writing tests, because the compiler catches many errors for you.
    * Minimize guesswork by using conventions for the most common tasks.
    * Help developers break things into discrete pieces so things are easy to share
      and maintain in the future.
    * Minimize boilerplate code so it's easy to focus on what your app does better
      than everyone else.

    Lucky was designed for developers that love making fast and reliable products.
    We think you'll love it.

    ## Spend less time writing tests and debugging

    [Type safe database queries](#{Guides::Database::QueryingDeleting.path}), [rock solid
    routing](#{Guides::HttpAndRouting::RoutingAndParams.path}), [type safe forms and
    validations](#{Guides::Database::ValidatingSaving.path}), and more. This is how Lucky helps you
    find errors before they reach your customers, write fewer tests, and spend less
    time fixing embarrassing bugs.

    ## Type safe database queries

    Lucky will help catch bad queries at compile time. Everything is chainable and
    the methods you can use are determined by the type. So strings can use `ilike`
    and `lower`, but if you try to use those on an integer column, Lucky will tell
    you at compile time that it won't work.

    ```crystal
    # Users that are 30 or older, are admins and whose email ends with thoughtbot.com
    UserQuery.new.age.gte(30).admin(true).email.ilike("%thoughtbot.com")
    ```

    ## Send content to users _fast_

    Lucky helps you spend less time fixing performance issues, and more time
    delighting your customers with fast applications.

    ```bash
    # HTML and JSON with thousands of nodes render in a couple milliseconds
    # This is rendering the Lucky welcome page in 1/10th of a millisecond
    Rendered GET / - 200 (94.0µs)
    ```

    ## Strong type safety with minimal boilerplate

    Lucky generates type safe and reliable code for you and makes things type safe
    that many frameworks can't or don't. This means you spend less time shipping
    embarrassing bugs to customers.

    For example, when you [define a model](#{Guides::Database::Models.path}) it will
    create some classes and methods for querying, creating, and updating records in
    a type safe way. If you write a query with a mistyped column name or with the
    wrong type, Crystal will let you know. If you try to save a field that doesn't
    exist or has a different type, it'll let you know.

    ## Avoid `nil` errors

    Instead of nil errors in production, Crystal and Lucky tell you about nil errors
    at compile time, before your customers ever see them. Lucky has designed its
    [router], [HTML], [actions], params, and [operations] so that Crystal can catch as
    many `nil` errors as possible.

    [router]: #{Guides::HttpAndRouting::RoutingAndParams.path}
    [HTML]: #{Guides::Frontend::RenderingHtml.path}
    [actions]: #{Guides::HttpAndRouting::RoutingAndParams.path}
    [operations]: #{Guides::Database::ValidatingSaving.path}

    ## Catch missing assets at compile time

    Instead of wondering why an image or other asset isn't showing up on the page,
    Lucky will catch it for you at compile time. It checks a list of all available
    assets and will even suggest the right one if you have a typo.

    ```plaintext
    "images/logo.jpeg" does not exist in the manifest
    Did you mean "images/logo.jpg"?
    ```

    ## Reliable and future proof configuration

    Lucky will fail to start if you forget a required configuration option and
    will tell you exactly which one is missing.

    It will also fail to compile if one of your dependencies changes its
    configuration options and let you know what to do to fix it.

    ```crystal
    LuckyWeb::Session::Store.configure do |settings|
      settings.key = "my_app"
    end

    # When you try to compile, you'll see this error because
    # LuckyWeb::Session::Store has marked "secret" as required
    ```

    ```plaintext
    LuckyWeb::Session::Store.settings.secret was nil, but the setting is required. Please set it.

    Example:

      LuckyWeb::Session::Store.configure do |settings|
        settings.secret = "some_value"
      end
    ```

    ## Update dependencies with confidence

    Updating your dependencies will always be difficult, but Crystal makes it a bit
    easier. If a method name changes or its arguments are different from the
    previous version, Crystal will catch it. This makes it much safer to update
    dependencies without introducing bugs.

    ## Friendly to new team members

    Lucky generates a `script/setup` script so it's easy to get started with your Lucky
    project. On top of that Lucky uses Crystal's type safety to its fullest so that
    new team members can make changes without worrying so much about breaking the
    app.

    ## Powerful HTML layouts and components

    Lucky uses [Crystal classes and methods to generate
    HTML](#{Guides::Frontend::RenderingHtml.path}). It may sound crazy at first, but the advantages
    are numerous.

    Never accidentally print `nil` to the page, extract and share partials using
    regular methods. Easily read an entire page by looking at just the render
    method. Text is automatically escaped for security. And it's all type safe. That
    means no more unmatched closing tags, and never rendering a page with missing data.

    ## Fault proof HTTP verbs

    REST can be a bit unwieldy at times. It's easy to use the right path and wrong
    verb and then wonder why the router can't find a matching route. Lucky makes
    this easy by setting both the path and HTTP method when generating links, forms,
    and redirects.

    ```crystal
    # Lucky will set the path and the DELETE HTTP method
    link "Delete", to: Tasks::Delete.with(task_id: task.id)
    ```

    ## Built in live reloading with Browsersync

    CSS and JS reload almost instantly, and every change to source code is
    automatically recompiled and the page is refreshed. On top of that,
    [Browsersync](https://www.browsersync.io) lets you connect through a proxy to
    easily test pages on your mobile device, or simulate slow connections to make
    sure all your customers are happy, even on slow connections.

    ## Never let an unhandled form param through

    Lucky makes sure only allowed parameters are saved to the database. It even
    catches issues at compile time when you try to add a form input for a parameter
    that isn’t allowed to be filled out.

    ```crystal
    # An operation that is used to register a new user
    class RegisterUser < User::SaveOperation
      permit_columns name, email # company_name is not allowed to be filled out
    end

    # An HTML form for a user to fill out
    operation = RegisterUser.new
    form_for Registrations::Create do
      # Will fail to compile because this field is not allowed
      text_input operation.company_name
    end
    ```
    MD
  end
end
