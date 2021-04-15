class Guides::Testing::HtmlAndInteractivity < GuideAction
  guide_route "/testing/html-and-interactivity"

  def self.title
    "Testing HTML and Interactivity"
  end

  def markdown : String
    <<-MD
    ## About Flow

    LuckyFlow is a shard that allows you to programmatically control a browser. This is best used
    to test your front-end and how users directly interact with your website in a browser.

    The name "flow" comes from the idea that a user will follow a "flow" from some starting point
    to some ending point. (e.g. Clicking login, entering login details, and being redirected to a dashboard)

    LuckyFlow is automatically installed and configured with Lucky full (or web) projects.
    API based projects don't need it since there's no HTML, CSS, or JavaScript.

    ## Setup

    LuckyFlow uses [chromedriver](https://chromedriver.chromium.org/) to control Selenium under the hood.
    You don't need anything installed as LuckyFlow will automatically install the chromedriver for you
    when it runs the first time.

    The LuckyFlow configuration settings are located in `spec/setup/configure_lucky_flow.cr`.

    ```crystal
    # spec/setup/configure_lucky_flow.cr
    LuckyFlow.configure do |settings|
      settings.stop_retrying_after = 200.milliseconds
      settings.base_uri = Lucky::RouteHelper.settings.base_uri
      settings.retry_delay = 10.milliseconds

      # Change where screenshots are stored
      settings.screenshot_directory = "./tmp/screenshots"

      # Point to a different Chrome browser than the default
      settings.browser_binary = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

      # Specify a custom location to the driver
      settings.driver_path = "/path/to/driver"

      # Change which driver is loaded. (`LuckyFlow::Drivers::HeadlessChrome` is default)
      settings.driver = LuckyFlow::Drivers::Chrome
    end
    ```

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
    post = PostFactory.create
    visit Posts::Show.with(post.id)
    ```

    ### Using `as` to sign users in

    Lucky comes built-in with a backdoor in tests so that you don’t need to go through the full process of
    loading the sign in page and filling out the form. Instead you can use the `as` option to visit the page
    and sign the user in automatically:

    ```crystal
    user = UserFactory.create
    post = PostFactory.create
    visit Posts::Show.with(post.id), as: user
    ```

    > Check out the `Auth::SignInThroughBackdoor` mixin to see how the backdoor works.

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

    ### Using `@` to find by Flow ID

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

    ### Hover over an element

    ```crystal
    el("@file-upload-box").hover
    ```

    ### Checking visiblity of an element

    ```html
    <style>
    .alert-box { display: none; }
    .upload-zone:hover + .alert-box { display: block; }
    </style>
    <div class="upload-zone" flow-id="file-upload-box">Drop Files Here</div>
    <div class="alert-box">Ready for upload!</div>
    ```

    ```crystal
    el(".alert-box").displayed? #=> false

    el("@file-upload-box").hover

    el(".alert-box").displayed? #=> true
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

    ### Filling select fields

    To fill the value of a `<select>` tag, use the `flow.select()` method.

    ```html
    <select name="cars" flow_id="car-list">
      <option value="ford">Ford</option>
      <option value="honda">Honda</option>
      <option value="tesla">Tesla</option>
    </select>
    ```

    ```crystal
    flow.select("cars", value: "honda")
    flow.el("@car-list").value.should eq "honda"
    ```

    If you need to fill multiple values for a `<select multiple>` tag, you can pass an array.

    ```crystal
    flow.select("cars", value: ["honda", "toyota"])
    ```

    Check if a specific value is selected using the `selected?` method.

    ```crystal
    flow.el("option[value='tesla']").selected? #=> false
    flow.el("option[value='toyota']").selected? #=> true
    ```

    ## Interacting with JavaScript

    ### Dismissing alerts

    If your page as a `confirm()` modal, you can `accept` or `dismiss` with the `accept_alert` or `dismiss_alert` methods.

    ```crystal
    flow.click("@delete-comment-button")
    flow.accept_alert

    flow.click("@back-button")
    flow.dismiss_alert
    ```

    > For javascript `alert()` modals, the `accept_alert` and `dismiss_alert` do the same thing.

    ## Spec Assertions

    LuckyFlow comes with a few methods for asserting elements exist

    ### Asserting elements are on the page

    You can use `el` combined with the `be_on_page` matcher to assert that an
    element is on the page:

    ```crystal
    el("@post-title", text: "My post").should be_on_page
    ```

    ### Asserting the current URL path

    You can use `have_current_path` to check that the page you are on matches the path you expect

    ```crystal
    flow = BaseFlow.new
    flow.visit Authenticated::Endpoint::Index
    flow.should have_current_path(SignIn::New)
    ```

    ### Asserting an element's text

    The `have_text` will test that an element contains a piece of text.

    ```html
    <ul flow_id="user-list">
      <li>Natasha</li>
      <li>Steve</li>
      <li>Tony</li>
      <li>Bruce</li>
    </ul>
    ```

    ```crystal
    el("@user-list").should have_text("Tony")
    ```

    ## Managing Cookies

    You can access cookies using the flow's `session.cookie_manager`.

    ```crystal
    flow = SomeFlow.new

    flow.visit SomePage::Index

    flow.session.cookie_manager.add_cookie("hello", "world")
    flow.session.cookie_manager.get_cookie("hello") #=> "world"
    ```

    ## Debugging

    For debugging tips with LuckyFlow, read our [Debugging Tests](#{Guides::Testing::DebuggingTests.path}) guide.
    MD
  end
end
