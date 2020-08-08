abstract class PageLayout
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
      mount Shared::LayoutHead, seo: SEO.new(page_title), context: @context

      body class: "font-sans text-grey-darkest leading-tight bg-grey-lightest" do
        mount Shared::Header, @context.request
        div class: "flex flex-col container mx-auto min-h-screen" do
          content
        end
        mount Shared::Footer
      end
    end
  end
end
