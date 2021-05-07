class Guides::Tutorial::Design < GuideAction
  guide_route "/tutorial/design"

  def self.title
    "New Home page and some Design"
  end

  def markdown : String
    <<-MD
    ## Swapping out the HomePage

    It's nice that we can boot our application and see a home page, but we know that page won't stick around.
    We will swap it out for our own Home page to make this site a little more ours.

    First, we should create a new `Page`. We will use the `gen.page` cli task. Enter `lucky gen.page Home::IndexPage`.

    ```bash
    lucky gen.page Home::IndexPage
    ```

    This will generate a new `Page` class in `src/pages/homes/index_page.cr` which we will need to make a small change
    in. Open that file, and update this code:

    ```diff
    # src/pages/homes/index_page.cr
    - class Home::IndexPage < MainLayout
    + class Home::IndexPage < AuthLayout
    ```

    The `MainLayout` is currently setup to be our site layout for users logged in to the app.
    The `AuthLayout` is used for pages like the login/signup pages, and now our Home Page. Eventually, you'll
    be creating your own layouts to better suit your needs.

    Next, we need to tell our root action to render our new page instead of the default Lucky page. Open up your
    `Home::Index` action in `src/actions/home/index.cr`. Update this code:

    ```diff
    # src/actions/home/index.cr
    - html Lucky::WelcomePage
    + html Home::IndexPage
    ```

    The `html` macro here will take the page class we want to render, and mix the `content` with our layout.

    > For more information on rendering HTML, read the [Rendering HTML](#{Guides::Frontend::RenderingHtml.path}) guide.

    ## Updating the Layout

    As mentioned previously, we currently have two separate layouts. One for when users are logged in `MainLayout`, and one for
    when users are logged out `AuthLayout`. These files live in the root of your `src/pages/` directory. We will update our `AuthLayout`
    to start so we can get a feel for writing HTML in Lucky.

    When it comes to writing HTML in Lucky, we use plain Crystal methods that generate HTML for us!
    [Read the HTML guide](#{Guides::Frontend::RenderingHtml.path}) for more details.

    ### Anatomy of the layout

    Open up the `AuthLayout` in `src/pages/auth_layout.cr`. This file has a `render` method which contains the start to our HTML. Within this method
    are several other Crystal methods like `html_doctype`, `html`, and `body` which should be pretty recognizable. Any HTML tag has an associated method
    you can call from here. In addition, there's a few helper methods which are explained more in the [HTML guide](#{Guides::Frontend::RenderingHtml.path}).

    Two methods that may look unfamiliar are `mount`, and the `content` method you see inside of the `body` block.
    The `mount` is related to [Components](#{Guides::Frontend::RenderingHtml.path(anchor: Guides::Frontend::RenderingHtml::ANCHOR_COMPONENTS)})
    which we will cover later. The `content` method is used to render the page content from pages that inherit from this layout.
    For example, our `Home::IndexPage` inherits from `AuthLayout`, so the `Home::IndexPage` has a `content` method where all of the Home page HTML will go.

    ### Adding a wrapper

    Let's update the `html` block, and replace it with this code:

    ```crystal
    # src/pages/auth_layout.cr
    html class: "h-100", lang: "en" do
      mount Shared::LayoutHead, page_title: page_title, context: context

      body class: "d-flex flex-column h-100" do
        mount Shared::FlashMessages, context.flash
        main class: "flex-shrink-0" do
          content
        end

        footer class: "footer mt-auto py-3 bg-light" do
          div class: "container" do
            span "CloverApp", class: "text-muted"
          end
        end
      end
    end
    ```

    As you can see, we can write methods that match up with HTML tags like `span`, `div`, `main`, and `footer`. We can
    even add our own custom CSS classes by using the `class: ""` argument of each tag method.

    Boot up your app, and give it a shot! See that you now have "CloverApp" displaying below the content of your Home page.

    ## Adding a CSS framework

    If you haven't guessed by now, we've started adding [Bootstrap](https://getbootstrap.com/) classes to our HTML. You're free
    to use any (or no) CSS framework you wish. There are no limitations since Lucky includes [LaravelMix](https://laravel-mix.com/)
    which just wraps Webpack. We will stick with Bootstrap just for the purposes of this Tutorial.

    ### Installing a CSS framework

    Lucky uses `yarn` by default, so this tutorial will as well. If you prefer a different installation you may use that.

    Before we install Bootstrap, we should shut down our server. (`ctrl-c`) Then from the terminal, we can run:

    ```bash
    yarn add bootstrap
    ```

    Next we will import it in our stylesheet. Open up `src/css/app.scss`. You'll find some default normalize styles in here. Now that we're using
    a CSS framework, all of these can go away! Replace everything with this code:

    ```scss
    // src/css/app.scss
    @import "bootstrap";
    ```

    > For more information on handling assets, read the [Asset Handling](#{Guides::Frontend::AssetHandling.path}) guide.

    ## Updating the Home Page

    Now that we have a layout, we can update our Home page to match our new styles.

    Open up the `Home::IndexPage` file in `src/pages/home/index_page.cr`. In here, we will see the `content` method defined.
    This is the method that's called in the `AuthLayout` class. In this `content` method we can see the `h1` method. Let's update
    that with this code:

    ```crystal
    # src/pages/home/index_page.cr
    def content
      div class: "px-4 py-5 my-5 text-center" do
        h1 "CloverApp", class: "display-5 fw-bold"
        div class: "col-lg-6 mx-auto" do
          para "It's your Lucky day! See a fortune, and share the luck.", class: "lead mb-4"
          div class: "d-grid gap-2 d-sm-flex justify-content-sm-center" do
            link "Join", to: SignUps::New, class: "btn btn-primary btn-lg px-4 me-sm-3"
            link "Login", to: SignIns::New, class: "btn btn-outline-secondary btn-lg px-4"
          end
        end
      end
      div class: "container" do
        # we will use this later
      end
    end
    ```

    Notice that we're using the `link` method. Your first thought might be "Why would we use the `<link>` tag here?".
    This is one of the few exceptions to the "every tag has an associated method" rule. In this case `link` creates an anchor tag `<a></a>`.
    The `to:` argument takes a Lucky Action class allowing the links to be type-safe and more future proof.

    The other new tag here is `para`. This replaces the `<p></p>` tag due to Crystal already having a `p()` method used for printing to STDOUT.

    > For more information on special tags, read the [Special Tags](#{Guides::Frontend::RenderingHtml.path(anchor: Guides::Frontend::RenderingHtml::ANCHOR_SPECIAL_TAGS)})
    > guide in Rendering HTML.

    ## Your Turn

    We've created a layout and a new home page. Now it's your turn to play with some HTML.

    Try this:

    * Add a copyright note to your footer that always displays the current year.
    * Create a custom CSS style using normal raw CSS in your `src/css/app.scss`.
    * Apply that custom style to a tag on your Home Page.
    * Update the styles for your Login / Signup pages

    > If you have existing HTML you want to convert try the [HTML to Lucky Converter](#{HtmlConversions::New.path}) utility.

    MD
  end
end
