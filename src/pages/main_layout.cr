abstract class MainLayout
  include Lucky::HTMLPage

  abstract def content
  abstract def page_title

  # The default page title. It is passed to `Shared::LayoutHead`.
  #
  # Add a `page_title` method to pages to override it. You can also remove
  # This method so every page is required to have its own page title.
  def page_title
    "Welcome"
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead.new(page_title: page_title, context: @context)

      body class: "font-sans text-grey-darkest leading-tight bg-grey-lighter" do
        mount Shared::Header.new(@context.request)
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
        render_feature_grid
        render_freeform_text
      end
    end
  end

  private def render_feature_grid
    div class: "container text-center md:text-left mx-auto px-6 py-5 bg-white md:bg-transparent border-b border-grey-light md:border-none" do
      mount Shared::FlashMessages.new(@context.flash)
      div class: "flex flex-col md:flex-row md:bg-white mx-auto md:rounded-lg md:shadow md:-mt-12 md:px-5 md:py-12" do
        content_block "Say goodbye to slow", <<-TEXT
        A simple hello world response is returned in 0.1ms. Rendering
        complex JSON usually takes only a few milliseconds.
        TEXT

        content_block "Batteries included", <<-TEXT
        Authentication, asset management, CORS, database ORM, and more can
        all be included when creating a new Lucky project.
        TEXT

        content_block "Fewer bugs. More joy", <<-TEXT
        Instead of finding bugs in QA or in production, Lucky is designed to
        catch as many bugs as possible at compile time.
        TEXT
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
    div class: "container mx-auto px-6 lg:px-32 markdown-content my-16" do
      div class: "lg:px-16" do
        raw CustomMarkdownRenderer.render_to_html <<-TEXT
        ### Why is modern web development so complicated?

        **There are more choices in tech than ever**, and with it comes more questions and more complexity.

        Have you ever thought:

        * "Why do I have to write **so much boilerplate**?"
        * "How do **so many bugs make it to production**?"
        * "Why is my app **so slow**!?"
        * "Why do I have to choose between fast prototyping and long term maintainability?"

        Every performance issue and every bug steals precious time from making your service better.

        ### What if you could get something up quickly *and* maintain it for years to come?

        Imagine this:

        * Generators for quick code creation
        * Built in authentication (Optional)
        * Secure by default
        * Built in Webpack config to get a SPA off the ground fast (Optional)
        * Insanely fast execution so users aren’t left waiting
        * Powerful type system that helps catch bugs before they ever hit production

        If this sounds interesting, [let's get started](#{Guides::GettingStarted::Installing.path}).

        ### Is Lucky right for me?

        Lucky is new software. Don't see a feature that you need? Not sure
        Lucky is right for you?

        Lucky is in active development and we'd love
        to hear what features you need. Join us in our
        [chatroom](https://gitter.im/luckyframework/Lobby) and keep up to
        date date by [subscribing to our
        blog](#{Blog::Index.path}) or [following us on
        Twitter](https://twitter.com/luckyframework).
        TEXT
      end
    end
  end
end
