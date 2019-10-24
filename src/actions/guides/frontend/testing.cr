class Guides::Frontend::Testing < GuideAction
  guide_route "/frontend/testing"

  def self.title
    "Testing HTML and Interactivity"
  end

  def markdown : String
    <<-MD
    ## Setup

    LuckyFlow is automatically installed and configured with Lucky projects
    (excluding projects generated with the `—api` option)

    For tests to run you will need to install Chrome and Chromedriver:

    ### On macOS

    `brew cask install chromedriver`

    ### On Linux

    `sudo apt-get install chromium-chromedriver` or
    https://makandracards.com/makandra/29465-install-chromedriver-on-linux

    ## A quick overview of flows

    LuckyFlow provides methods for visiting pages, clicking and interacting with
    elements, and filling forms.

    ### Create a Flow spec in spec/flows/

    When writing flow specs, it’s best to *write the spec as a full flow that a
    user might take*. For example, here is a flow for publishing an article:

    ```crystal
    # spec/flows/publish_post_spec.cr
    describe "Publish post flow" do
      it "works successfully" do
        flow = PublishPostFlow.new

        flow.start_draft
        flow.create_draft
        flow.draft_should_be_saved
        flow.open_draft
        flow.publish_post
        flow.post_should_be_published
      end
    end
    ```

    ### Create a Flow object

    Then create a Flow object that performs the interactions and assertions:

    ```crystal
    # spec/support/flows/publish_post_flow.cr
    class PublishPostFlow < BaseFlow
      def start_draft
        visit Articles::Index
        click "@new-post"
      end

      def create_draft
        fill_form SaveArticle,
          title: "Draft Post",
          body: "body"
        click "@save-draft"
      end

      def draft_should_be_created
        draft_title.should be_on_page
      end

      def open_draft
        draft_title.click
      end

      private def draft_title
        el("@draft-title")
      end

      def publish_post
        fill_form PublishArticle,
          title: "Published Post"
        click "@publish-post"
      end

      def post_should_be_published
        el("@post-title", text: "Published Post").should be_on_page
      end
    end
    ```

    ## Visiting pages

    You can visit pages with some built-in methods that accepts strings and Lucky
    routes.

    ### Using with Lucky actions

    ```crystal
    # Visit an action that does not need params
    visit Home::Index

    # Visit a route that takes params
    post = PostBox.create
    visit Posts::Show.with(post.id)
    ```

    ### Using `as` to sign users in

    Lucky comes built-in with a backdoor in tests so that you don’t need to go through the full process of loading the sign in page and filling out the form. Instead you can use the `as` option to visit the page and sign the user in automatically:

    ```crystal
    user = UserBox.create
    post = PostBox.create
    visit Posts::Show.with(post.id), as: user
    ```

    > Check out the `Auth::SignInThroughBackdoor`  mixin to see how the backdoor works.

    ### Using strings paths

    You should generally use Lucky routes but if you need to you can use strings to visit a path
    ```crystal
    visit "/posts"
    ```

    ## Finding elements

    You can work with elements using the `el` method.

    Note that *finding elements with `el` is lazy*. That means that when you call
    `el` it will not fail if it can’t find an element, because it won’t try to
    find the element until you try to interact with it or check if it is in the
    page.

    ### Using `@`  to find by Flow ID

    If you are familiar with other libraries for interacting with pages, you
    likely have found elements using CSS or by the text inside of elements. This
    can be brittle because CSS and text can change and then break your tests even
    though the feature still works.

    Instead of using CSS or text, you can use the special `@` selector for
    interacting with elements. This uses an HTML attribute called `flow-id`:

    ```crystal
    # Looks for an element with an HTML attribute called "flow-id"
    # with the value "view-posts"
    el("@view-posts")
    ```

    Using this in a Lucky page is simple:

    ```crystal
    # LuckyFlow will find this element
    link "View Posts", Posts::Index, flow_id: "view-posts"
    ```

    ### Finding with CSS

    You can also find elements by CSS, but using Flow IDs is preferred because
    your tests will be more resilient to change.

    In the cases when you do need to use CSS, here’s how you would do it:

    ```crystal
    # look for an anchor tag with the "post-title" class
    el("a.post-title")
    # look for an element with an id of "post-button"
    el("#post-button")
    ```

    ### Finding elements that contain text

    Sometimes you want to only find elements that contain certain text. Use the
    `text` option:

    ```crystal
    el("a.post-title", text: "Title of post")
    el("@post-title", text: "Title of post")
    ```

    ## Interacting with elements

    ### Clicking an element

    ```crystal
    el("@save-button").click
    el("a.post-title", text: "My title").click
    # Or use the shortcut method `click`
    click "@save-button"
    click "a.post-title"
    ```

    ### Filling and submitting forms

    Fill forms rendered by Lucky:

    ```crystal
    fill_form SavePost,
      title: "My Post",
      body: "Post body"
    ```

    You can also fill forms based on the input’s  `name`:

    ```crystal
    fill "post:title", with: "My Post"
    ```

    Or use the `fill`  method on an element:

    ```crystal
    el("#title-field").fill("My Post")
    ```

    ## Asserting elements are on the page

    You can use `el` combined with the `be_on_page` matcher to assert that an
    element is on the page:

    ```crystal
    el("@post-title", text: "My post").should be_on_page
    ```
    MD
  end
end
