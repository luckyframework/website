abstract class BlogLayout
  include Lucky::HTMLPage

  abstract def content
  abstract def page_title
  abstract def middle_section

  needs title : String

  def page_title
    @title
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead.new(seo: SEO.new(page_title), context: @context)

      body class: "font-sans text-grey-darkest leading-tight bg-grey-lightest" do
        mount Shared::Header.new(@context.request)
        div class: "bg-lucky-teal-blue-gradient" do
          div class: "flex container mx-auto" do
            middle_section
          end
        end
        div class: "flex flex-col container mx-auto min-h-screen" do
          content
        end
      end

      mount Shared::Footer.new
    end
  end
end
