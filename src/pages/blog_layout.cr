abstract class BlogLayout
  include Lucky::HTMLPage

  abstract def content
  abstract def page_title

  needs title : String

  def page_title
    @title
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead.new(page_title: page_title, context: @context)

      body class: "font-sans text-grey-darkest leading-tight bg-white" do
        mount Shared::Header.new(@context.request)
        middle_section
        div class: "flex flex-col container mx-auto min-h-screen" do
          content
        end
      end
    end
  end

  def middle_section
    div class: "bg-green-gradient" do
      div class: "flex container mx-auto" do
        div class: "mx-auto w-full md:w-3/4 lg:w-3/5 xl:w-1/2 pt-12 pb-16" do
          h1 "Want to stay up to date?", class: " text-white font-normal text-2xl mb-3 text-shadow"
          div class: "flex flex-row w-full shadow rounded-lg" do
            input type: "email", class: "bg-white p-4 text-lg w-full rounded-l-lg", placeholder: "Enter your email"
            input type: "submit", value: "Subscribe", class: "py-3 px-5 text-shadow rounded-r-lg cursor-pointer text-white bg-lucky-teal-blue text-lg"
          end
        end
      end
    end
  end
end
