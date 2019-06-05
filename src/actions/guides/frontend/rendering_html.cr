class Guides::Frontend::RenderingHtml < GuideAction
  guide_route "/frontend/rendering-html"

  def self.title
    "Rendering HTML"
  end

  def markdown
    <<-MD
    ## Rendering a page

    Let's say we have an action and we want to render all of our user's names:

    ```crystal
    # in src/actions/users/index.cr
    class Users::Index < BrowserAction
      route do
        # Renders the Users::IndexPage
        render IndexPage, user_names: ["Paul", "Sally", "Jane"]
      end
    end
    ```

    ## Creating a page

    Let's create the page for our `Users::Index` action. You can generate a file
    quickly with `lucky gen.page Users::IndexPage`, then modify it:

    ```crystal
    # in src/pages/users/index_page.cr
    class Users::IndexPage < MainLayout
      needs user_names : Array(String)

      def content
        ul class: "my-user-list" do
          @user_names.each do |name|
            li name, class: "user-name"
          end
        end
      end
    end
    ```

    Woo hoo! We created our first page. Let's walk through what's going on.

    ## Declaring what a page needs

    You’ll notice we used `needs` near the top of the class. This declares that for
    this page to render we need an Array of Strings and that they will be assigned
    to the `@user_names` variable. We set the user names by passing it in the
    `render` macro in our action: `render user_names: ["Paul", "Sally", "Jane"]`

    > This is nice because you won’t accidentally forget to pass something to a page
    ever again. If you forget, the compiler will tell you that you’re missing
    something.

    ## Rendering HTML in our page

    We then wrote a `content` method in our class to render our HTML. The
    `content` will be rendered in your `MainLayout` (defined in
    `src/pages/main_layout.cr`). Tags are generated with regular Crystal methods.
    Most all HTML5 tags are available by default.

    > Note that paragraph tags are `para` instead of `p` since `p` is already used
    by Crystal. You can use `pp` to debug output.

    ### Examples of using HTML tags

    ```crystal
    # Generate a ul tag with no other options (class, data attributes, etc), and render tags within it
    ul do
      li "Hey!"
    end

    # Generate a ul tag with options and more tags within it
    ul class: "my-list", data_foo: "bar" do
      li "Excellent list item"
    end

    # Generate a tag with the text as it's content
    h1 "My cool test"

    # Generate a tag with the text as content and with options
    h1 "My cool test", class: "app-header"
    ```

    Order and nesting works about the same as how you would write normal HTML.

    ```crystal
    def content
      # You can have a list
      ul do
        li "List item"
      end

      # And underneath it render something else
      footer "Copyright Notice"
    end
    ```

    ### Creating custom HTML tags

    If you need to create a non-standard HTML tag for your application, you can use the `tag` method.

    ```crystal
    def content
      # Renders <my-custom-tag class="special control">Special</my-custom-tag>
      tag("my-custom-tag", class: "special control") do
        text "Special"
      end
    end
    ```

    ### Examples of HTML attributes

    All of the HTML tag methods allow for passing in any HTML attribute.

    ```crystal
    def content
      div(id: "someID", class: "row highlight special") do
        span "A special code", class: "text-note"
      end
    end
    ```

    If you need to pass in data attributes, or any arbitrary attributes for use in SPAs (i.e. ng-app, v-bind:click, etc...), you can also use a string.

    ```crystal
    def content
      div(ng_model: "something", data_action: "someAction", "v-bind:click": "update")
    end
    ```

    In some cases, you find that you want to use [boolean attributes](http://w3c.github.io/html/infrastructure.html#sec-boolean-attributes) for forms or working with SPAs. For these, you just pass an `Array(Symbol)` to the `attrs` option for the tag.

    ```crystal
    def content
      # Renders <div id="application" ng-app></div>
      div(id: "application", attrs: [:ng_app])

      # Renders <button disabled>Click</button>
      button("Click", attrs: [:disabled])
    end
    ```

    > NOTE: Lucky will automatically run attributes through a dasherize inflector. This means underscores will become a dash once rendered. (e.g. `:ng_app` becomes `ng-app`). In more complex cases like you see in Vuejs, crystal allows you to use quotes like in `:"v-bind:click"`

    ## Special tags (link, form helpers, etc.)

    There are a few specials helpers that make it easier. For creating links with an
    anchor tag, we have the `link` helper.

    ```crystal
    link "Link Text", to: "/somewhere", class: "some-html-class"

    # The real power comes when used with route helers from actions
    link "Show user", to: Users::Show.with("user_id"), class: "some-html-class"

    # Leave off `with` if an route doesn't need params
    link "List of users", to: Users::Index
    ```

    When you pass a route helper as we did with `Users::Show.with("user_id")`, the
    link helper automatically sets the path *and* the correct HTTP verb.

    Since the HTTP verb (`GET`, `POST`, `PUT`, etc.) is automatically used by `link`
    we can do delete links like this:

    ```crystal
    # data-method="delete" will automatically be set.
    # This means the link submits with the right HTTP verb automatically.
    link "Delete", to: Users::Delete.with("user_id")

    # You can use the same nesting as with most other tags
    link to: Users::Delete.with("user_id"), class: "delete-link" do
      img src: asset("images/delete-icon.svg")
    end
    ```

    > Since the link automatically includes the HTTP verb, you are guaranteed at
    compile time that the link will go to the right place.

    ### Gotchas when using `link`

    Crystal will search for constants (classes and modules) in the current
    namespace first. This usually works fine, but there are times when Crystal
    may not know how to find the correct constant. In this case you can prefix
    the constant with `::` to look at the root namespace. This is best explained
    with an example.

    Let's say we have a nested action and a non-nested action like this:

    ```crystal
    # Tasks nested in Projects namespace
    class Projects::Tasks::Index < BrowserAction
      # call the action
    end

    # Tasks is not nested
    class Tasks::Show < BrowserAction
      # call the action
    end
    ```

    Crystal will incorrectly look for `Tasks::Show` in `Projects::Tasks`:

    ```crystal
    class Projects::Tasks::IndexPage < MainLayout
      def content
        # Crystal will look for Projects::Tasks::Show since it is called within
        # Projects::Tasks. Crystal will see the Tasks constant and assume that's
        # what we want
        link "View task", Tasks::Show.with(123)
      end
    end
    ```

    To fix this, prefix the call constant with `::`

    ```crystal
    # This tells Crystal to look for the top-level Tasks constant
    link "View task", ::Tasks::Show.with(123)
    ```

    ### Rendering HTML forms

    There are some helpers for rendering HTML forms. For more info see the [saving
    data with forms](#{Guides::Database::ValidatingSavingDeleting.path(anchor: Guides::Database::ValidatingSavingDeleting::ANCHOR_USING_WITH_HTML_FORMS)}) guide.

    ### Other special helpers

    * `html_doctype` - Renders `<!DOCTYPE html>`
    * `css_link(href, **options)` - Renders a `<link rel="stylesheet" media="sceen">` tag with `href` and any additional/override `options`
    * `js_link(src, **options)` - Renders a `<script>` tag with `src` and any additional/override `options`
    * `utf8_charset` - Renders a `<meta charset="utf8">` tag
    * `responsive_meta_tag` - Another meta tag for responsive design.
    * `nbsp(how_many = 1)` - Renders `&nbsp;` entity for the number of times in `how_many` (1 by default).
    * `raw` - Render RAW string to the page.

    > Note: Using `raw` can be dangerous and should **never** be used with unescaped user-generated data.

    ## Rendering text

    Sometimes you want to render plain text. To do that use the `text` method.

    > Strings rendered with `text` are automatically HTML escaped for security. Text
    passed to tags is also escaped.

    ```crystal
    div "email" do
      text "This is the email text"
      br
      span "inbox", class: "email-tag"
    end
    ```

    ### Render unescaped text

    ```crystal
    div "email" do
      # Use the `raw` method to render unescaped text
      raw "&middot;" # Render a middot HTML entity
    end
    ```

    ## Page helpers

    Formatting text on pages is pretty common. Lucky gives you several handy methods to help formatting.

    > Some page helpers return a `String`, and some page helpers will write directly to the page.

    ### Converting a number to currency format

    Returns a `String` formatted to a currency format.

    ```crystal
    # Returns standard U.S. format
    text number_to_currency(1234.43)
    # => $1234.43

    # Additional options supported for other formats
    text number_to_currency(1234.32, unit: "€", separator: ",", delimiter: ".")
    # => €1.234,32
    ```

    ### Truncating text

    Returns a `String` truncated to `length`.

    ```crystal
    text truncate_text("some really long text here", length: 12)
    # => some real...
    ```

    ### Truncating HTML

    Truncates the text, and writes HTML directly to the page.

    ```crystal
    truncate("Four score and seven years ago", length: 20) do
      link "Read more", to: "#"
    end
    # => "Four score and se...<a href="#">Read more</a>"
    ```

    ### Highlighting text

    This takes `phrases` in the form of `Array(String | Regex)` and wraps the matching phrases in a `<mark></mark>` tag.

    ```crystal
    highlight("From this taco meat we shall eat for days!", phrases: ["taco", /eat/])
    # => From this <mark>taco</mark> m<mark>eat</mark> we shall <mark>eat</mark> for days!
    ```

    ### Pluralizing a word

    Returns a `String` using the first arg to determine how to pluralize the second arg.

    ```crystal
    text "I have \#{pluralize(2, "shoe")}"
    # => I have 2 shoes
    ```

    ### Wrapping words

    Returns a `String`. Adds new lines (`\\n`) after the nearest word limited to `line_width`.

    ```crystal
    word_wrap("Maybe some code would go here", line_width: 6)
    # => Maybe \\nsome \\ncode \\nwould \\ngo \\nhere"

    # Change the new line character with `break_sequence`.
    word_wrap("Maybe some code would go here", line_width: 6, break_sequence: "<br>")
    # => Maybe <br>some <br>code <br>would <br>go <br>here"
    ```

    ### Simple text format

    Formats the text with some simple HTML and writes directly to the page.

    ```crystal
    simple_format("Nice\\neasy\\nformat!")
    # => <p>Nice<br>easy<br>format!</p>
    ```

    ### Sentence lists

    Returns a `String`, and creates a comma-separated sentence from the provided `Enumerable` list.

    ```crystal
    text to_sentence(["Tacos", "Burritos", "Salsa"])
    # => Tacos, Burritos, and Salsa
    text to_sentence(words, last_word_connector: " and ")
    # => Tacos, Burritos and Salsa
    ```

    > By default `to_sentence` will include a [serial comma](https://en.wikipedia.org/wiki/Serial_comma). Override that with the `last_word_connector` option.

    ### Excerpt from a paragraph

    Returns a `String`. Similar to `truncate_text`, but for the middle of a large body of text.

    ```crystal
    text excerpt("This is a beautiful morning", "beautiful", radius: 5)
    # => "...is a beautiful morn..."
    ```

    ## Layouts

    Pages have layouts that make it easier to share common elements.

    ### Layouts in a default Lucky application

    * `MainLayout` - The layout used when a user is signed in
    * `GuestLayout` - The layout used when the user is not signed in

    Pages inherit from `MainLayout`, `GuestLayout` or another layout you decide to create.
    Layouts can declare [abstract
    methods](https://crystal-lang.org/docs/syntax_and_semantics/virtual_and_abstract_types.html)
    or use
    [`responds_to?`](https://crystal-lang.org/docs/syntax_and_semantics/if_varresponds_to.html)
    for more advanced page layouts.

    ### Rendering page specific content in the layout

    Let's start with a quick example. In newly generated Lucky projects your
    layouts call `shared_layout_head`. This method is defined in
    `Shared::LayoutHead`. If you look in the `src/components/shared/layout_head`
    file you'll see that it defines and calls a `page_title` method.

    This means that you can customize the page title in your page by writing a
    `page_title` method:

    So to set a page specific title, do this:

    ```crystal
    # src/pages/users/index_page.cr
    class Users::IndexPage < MainLayout
      # Override the page_title method that was originally
      # defined in Shared::LayoutHead
      def page_title
        "List of users"
      end
    end
    ```

    This technique can be used to render other types of content, like a sidebar
    (similar to `content_for` in Rails):

    ```crystal
    # src/pages/main_layout.cr in the `render` method
    def render
      # Other layout code left out for brevity
      div class: "sidebar" do
        # Now pages can render content in a sidebar
        render_sidebar
      end
    end

    # This makes it so that every page needs to implement the sidebar method
    # https://crystal-lang.org/docs/syntax_and_semantics/virtual_and_abstract_types.html
    abstract def render_sidebar
    ```

    Then in a page:

    ```crystal
    class Users::IndexPage < MainLayout
      def content
        text "Rendering something in the main part of the layout"
      end

      def render_sidebar
        text "This is content for the sidebar"
      end
    end
    ```

    ### Using `render_if_defined` in layouts for optional content

    Sometimes pages have almost the same layout, but have just one or two parts
    that are optional. You can handle this with
    [`responds_to?`](https://crystal-lang.org/docs/syntax_and_semantics/if_varresponds_to.html)
    and `render_if_defined`.

    > `responds_to?` should be used when pages mostly look the same, but have just
    minor changes to the layout that happen on some pages. If pages look
    significantly different, consider extracting a new layout class instead.

    ```crystal
    # Put this in a layout's `render` method
    # This makes it so that pages can have an optional `help_message`.
    if responds_to?(:help_section)
      div class: "help-section" do
        render_if_defined :help_section
      end
    end

    # In a page with a help message
    class Admin::Users::IndexPage < MainLayout
      def help_section
        para "Click the 'export' button to export a CSV of all users"
      end
    end
    ```

    > Common layout components could be extracted to
    `src/components/shared/{component_name}.cr`. See ["Extract partials and shared code"](#extract-partials-and-shared-code)

    ## Extract partials and shared code

    Extracting code for reuse or clarity is easy since pages are made of classes and
    methods.

    ```crystal
    class Users::ShowPage < MainLayout
      def content
        render_user_header
      end

      # We can extract a private method to make our code easier to understand
      private def render_user_header
        div class: "user-header" do
          h1 "Users"
          link "Back to users index", to: Users::Index
        end
      end
    end
    ```

    ### Share between pages with a module

    ```crystal
    # in src/components/users/header.cr
    module Users::Header
      private def render_user_header
        div class: "user-header" do
          h1 "Users"
          link "Back to users index", to: Users::Index
        end
      end
    end

    # and use it in the view
    class Users::ShowPage < MainLayout
      include Users::Header

      def content
        render_user_header
      end
    end
    ```

    ## Sharing data used by all pages

    Let's say you want to show the currently signed in user on every page in a
    layout. It would be a pain to have to type `needs current_user : User` in every
    page and `expose current_user: find_the_user` in every action. Lucky's got you
    covered.

    ### Example using `needs` and `expose`

    You can add `needs` to the `MainLayout` if every page that uses that layout
    needs something.

    For actions, we have an `expose` macro that makes it easy to automatically pass
    data to rendered pages.

    The `expose` macro sends the results of a method to the page, as if you had passed
    it manually:

    ```crystal
    # Without `expose`
    class Users::Index < BrowserAction
      route do
        render current_user_name: current_user_name
      end

      private def current_user_name
        "Bobby"
      end
    end

    # The equivalent version using `expose`
    class Users::Index < BrowserAction
      expose current_user_name

      route do
        render
      end
    end
    ```

    ### Full example

    The best way to learn about `expose` and `needs` is to look at the default generated
    actions in `src/actions` such as the `BrowserAction` in `src/actions/browser_action.cr`.

    Then take a look at the layouts in `src/pages` to see how they use `needs`.

    It is also helpful to look at the action mixins in `src/actions/mixins` these
    declare the exposures and pipes for authentication.
    MD
  end
end
