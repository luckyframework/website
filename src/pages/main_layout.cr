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
          div class: "py-10 md:py-16 px-6 sm:px-10 max-w-md mx-auto text-center text-white" do
            div class: "leading-normal uppercase" do
              h1 "Build stunning web applications", class: "font-bold text-3xl md:text-5xl"
              h1 "in less time", class: "font-light text-3xl md:text-5xl"
            end

            para class: "opacity-75 sm:px-10 leading-loose mt-10 text-lg sm:text-xl" do
              text <<-TEXT
              A Crystal web framework that catches bugs for you, runs
              incredibly fast, and helps you write code that lasts.
              TEXT
            end

            div class: "my-10" do
              link "View on GitHub", "https://github.com/luckyframework/lucky", class: "btn btn--blue w-full sm:w-auto sm:mr-5"
              link "Get Started", Guides::GettingStarted::Installing, class: "btn w-full sm:w-auto mt-6 sm:mt-0"
            end
          end
        end
        render_main_content
      end
    end
  end

  private def render_main_content
    div class: "container mx-auto px-6" do
      mount Shared::FlashMessages.new(@context.flash)
      # TODO: Add real page content later
      # content
    end
  end
end
