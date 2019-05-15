class Shared::Header < BaseComponent
  needs request : HTTP::Request

  def render
    header class: "py-3 md:py-0 antialiased text-grey-light shadow-inner-bottom bg-lucky-blue" do
      div class: "container mx-auto" do
        div class: "flex justify-between items-center px-6" do
          div do
            link(Home::Index, class: "text-white mr-10 self-center") do
              img src: asset("images/logo.png"), class: "h-8"
            end
          end
          main_navigation
        end
      end
    end
  end

  private def main_navigation
    nav class: "justify-between flex items-center font-semibold" do
      nav_links
      docsearch_input
      docsearch_js
    end
  end

  private def nav_links
    nav_link("Guides", Guides::GettingStarted::Installing)
    nav_link("Chat", "https://gitter.im/luckyframework/Lobby")
    nav_link("Blog", Blog::Index)
    nav_link("GitHub", "https://github.com/luckyframework/lucky")
  end

  private def docsearch_input
    input id: "algolia-docsearch",
      type: "text",
      placeholder: "Search...",
      class: "w-32 bg-blue-darker appearance-none border-2 border-grey-dark rounded-full py-2 px-4 transition-base text-white leading-tight focus:text-black focus:w-48 focus:shadow-inner focus:outline-none focus:bg-white focus:border-teal"
  end

  private def docsearch_js
    script type: "text/javascript" do
      raw <<-JS
        window.docsearch({
          apiKey: '576424427b2189ea2d57cc245beaa67c',
          indexName: 'luckyframework',
          inputSelector: '#algolia-docsearch',
          debug: false // Set debug to true if you want to inspect the dropdown
        });
      JS
    end
  end

  private def nav_link(title, href, active : Bool = false)
    link title,
      to: href,
      class: "hidden md:block uppercase font-bold text-white tracking-wide no-underline mr-4 px-4 py-8 text-sm hover:bg-blue-darker hover:text-white"
  end
end
