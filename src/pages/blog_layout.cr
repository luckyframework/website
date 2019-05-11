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
end
