abstract class MainLayout
  include Lucky::HTMLPage

  abstract def content
  abstract def page_title

  # The default page title. It is passed to `Shared::LayoutHead`.
  #
  # Add a `page_title` method to pages to override it. You can also remove
  # This method so every page is required to have its own page title.
  def page_title
    "Web framework for Crystal"
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead.new(seo: SEO.new(page_title), context: @context)

      body class: "font-sans text-grey-darkest leading-tight bg-grey-lighter" do
        mount Shared::Header.new(@context.request)
        render_hero_content
        render_feature_grid
        render_freeform_text
      end
    end
  end

  private def render_hero_content
    div class: "bg-blue-gradient" do
      div class: "py-10 md:py-16 px-6 sm:px-10 mx-auto container text-center text-white" do
        div class: "mx-auto md:px-24 lg:px-32" do
          h1 class: "leading-normal text-blue-lightest font-light text-3xl md:text-4xl" do
            text "Build "
            span "lightning fast", class: "whitespace-no-wrap text-white italic mr-1 border-b-2 border-teal-light"
            text " web apps with "
            span "fewer bugs", class: "whitespace-no-wrap text-white italic border-b-2 border-teal-light"
          end

          para class: "text-blue-lighter lg:px-24 leading-loose mt-10 text-lg sm:text-xl" do
            text <<-TEXT
            Lucky is a web framework written in Crystal. It helps you
            work quickly, catch bugs at compile time, and deliver
            blazing fast responses.
            TEXT
          end

          div class: "my-10 md:mt-10 md:mb-8" do
            link "View on GitHub", "https://github.com/luckyframework/lucky", class: "btn btn--blue w-full sm:w-auto sm:mr-5"
            link "Get Started", Guides::GettingStarted::Installing, class: "btn w-full sm:w-auto mt-6 sm:mt-0"
          end
        end
      end
    end
  end

  private def render_feature_grid
    div class: "mx-auto container" do
      div class: "text-center lg:mx-5 md:text-left px-6 py-5 bg-white md:bg-transparent border-b border-grey-light md:border-none" do
        mount Shared::FlashMessages.new(@context.flash)
        div class: "flex flex-col md:flex-row md:bg-white mx-auto md:rounded-lg md:shadow md:-mt-12 md:px-5 md:py-12" do
          content_block "🚀 Say goodbye to slow", <<-TEXT
          Lucky is extremely fast and uses very little memory. You and
          your users will love the extra dose of speed.
          TEXT

          content_block "🔋 Batteries included", <<-TEXT
          Authentication, asset management, CORS, database ORM, and more can
          all be included when creating a new Lucky project.
          TEXT

          content_block "😁 Fewer bugs. More joy", <<-TEXT
          Instead of finding bugs in QA or in production, Lucky is designed to
          catch as many bugs as possible at compile time.
          TEXT
        end
      end
    end
  end

  private def content_block(title, body)
    div class: "w-full md:w-1/3 sm:px-0 md:px-8 my-5 md:my-0" do
      h3 title, class: "mb-3 text-black font-bold text-base"
      para body, class: "leading-loose text-sm text-grey-darker"
    end
  end

  private def render_freeform_text
    render_markdown_content <<-TEXT
    ## Why is modern web development so complicated?

    Have you ever thought:

    * "Why do I have to write **so much boilerplate**?"
    * "How do **so many bugs make it to production**?"
    * "Why is my app **so slow**!?"
    * "Why do I have to choose between fast prototyping and long term maintainability?"

    ## What if you could create something quickly **and** maintain it for years to come?

    * Generators for quick code creation
    * Built in authentication (Optional)
    * Secure by default
    * Built in Webpack config to get an SPA off the ground fast (Optional)
    * Insanely fast execution so users aren’t left waiting
    * Powerful type system that helps catch bugs before they ever hit production

    If this sounds interesting, [let's get started](#{Guides::GettingStarted::Installing.path}).

    ## What does Lucky look like?
    
    Lucky will generate **action classes** from class names that determine useful default routing path(s).
    The resulting classes map the routing path definition to a response block.
    
    Using separate classes allows to provide very [solid](https://thoughtbot.com/blog/designing-lucky-actions-routing) automatic
    error detection, as well as generation of routing, path, and link helpers and methods.
    
    ### JSON API

    ```crystal
    class Api::Users::Show < ApiAction
      get "/api/users/:user_id" do
        json user_json
      end

      private def user_json
        user = UserQuery.find(user_id)
        {name: user.name, email: user.email}
      end
    end
    ```

    ### Database

    ```crystal
    # Set up the model
    class User < BaseModel
      table :users do
        column last_active_at : Time
        column last_name : String
      end
    end

    # Add some methods to help query the database
    class UserQuery < User::BaseQuery
      def recently_active
        last_active_at.gt(1.week.ago)
      end

      def sorted_by_last_name
        last_name.lower.desc_order
      end
    end

    # Query the database
    UserQuery.new.recently_active.sorted_by_last_name
    ```

    ### Rendering HTML

    ```crystal
    class Users::Index < BrowserAction
      get "/users" do
        users = UserQuery.new.sorted_by_last_name
        render IndexPage, users: users
      end
    end

    class Users::IndexPage < MainLayout
      needs users : UserQuery

      def content
        ul class: "users-list" do
          @users.each do |user|
            li { link user.name, to: Users::Show.with(user) }
          end
        end
      end
    end
    ```

    ### JavaScript Components

    ```crystal
    class Home::IndexPage < MainLayout
      def content
        # Lucky includes Webpack!
        # You can enable React or Vue.js support. Then...

        # Mount your JavaScript component/app
        tag("MyApp", title: "MyApp is the best")

        # Optionally render regular HTML for non-interactive elements
        footer "Copyright MyApp 2019"
      end
    end
    ```

    ## Not quite ready to try Lucky?

    If you're not quite ready to dive in but want to stay up to date,
    [subscribe to our blog](#{Blog::Index.path}), or [follow us on
    Twitter](https://twitter.com/luckyframework).
    TEXT
  end

  private def render_markdown_content(markdown : String)
    div class: "container mx-auto px-6 lg:px-32 mt-8 mb-24" do
      div class: "lg:px-16" do
        div class: "markdown-content -large-code" do
          raw CustomMarkdownRenderer.render_to_html(markdown)
        end
      end
    end
  end
end
