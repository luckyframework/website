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
          h1 "Lucky Overview", class: "uppercase font-xl text-white text-shadow mb-6"
          ul class: "list-reset text-shadow text-lg mb-4" do
            5.times do
              li do
                link "#", class: "text-white block py-1 no-underline hover:underline" do
                  span "#", class: "opacity-75 mr-2 hover:no-underline"
                  text "Test item here"
                end
              end
            end
          end
        end
        mount Guides::Sidebar.new
      end
    end
  end
end
