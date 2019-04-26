class Shared::Header < BaseComponent
  needs request : HTTP::Request

  def render
    header class: "antialiased text-grey-light shadow-inner-bottom bg-lucky-blue" do
      div class: "container mx-auto px-6" do
        div class: "flex justify-between items-center px-6" do
          link(Home::Index, class: "text-white mr-10 self-center") do
            img src: asset("images/logo.png"), class: "h-8"
          end
          main_navigation
        end
      end
    end
  end

  private def main_navigation
    nav class: "justify-between flex items-center font-semibold" do
      nav_link("Guides", "#")
      nav_link("Chat", "#")
      nav_link("Blog", "#")
      nav_link("GitHub", "#")
      input class: "bg-gray-lighter appearance-none border-3 border-grey-lighter rounded-full py-2 px-4 text-grey-darker leading-tight focus:shadow-inner focus:outline-none focus:bg-white focus:border-green", placeholder: "Search...", type: "text"
      docsearch_js
    end
  end

  private def docsearch_js
    script type: "text/javascript" do
      raw <<-JS
        window.docsearch({
          apiKey: '576424427b2189ea2d57cc245beaa67c',
          indexName: 'luckyframework',
          inputSelector: '.algolia-docsearch',
          debug: false // Set debug to true if you want to inspect the dropdown
        });
      JS
    end
  end

  private def nav_link(title, href, active : Bool = false)
    link title,
      to: href,
      class: "uppercase font-bold text-white tracking-wide no-underline mr-4 px-4 py-8 text-sm hover:bg-blue-darker hover:text-white"
  end
end
