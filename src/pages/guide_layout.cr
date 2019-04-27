abstract class GuideLayout
  include Lucky::HTMLPage

  abstract def content
  abstract def page_title

  def page_title
    "Welcome"
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead.new(page_title: page_title, context: @context)

      body class: "font-sans text-grey-darkest leading-tight bg-grey-lighter" do
        mount Shared::Header.new(@context.request)
        middle_section
      end
    end
  end

  def middle_section
    div class: "bg-green-gradient" do
      div class: "flex relative py-8 pr-10 container mx-auto text-white" do
        div class: "w-sidebar ml-12"
        div class: "mt-5" do
          h1 "Lucky Overview", class: "uppercase font-xl text-white text-shadow"
        end
        mount Guides::Sidebar.new
      end
    end
  end
end
