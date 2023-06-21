class Shared::Header < BaseComponent
  needs request : HTTP::Request

  def render
    header class: "py-3 md:py-0 antialiased text-grey-light shadow-inner-bottom bg-lucky-blue" do
      div class: "container mx-auto" do
        div class: "flex flex-wrap md:flex-no-wrap justify-between items-center md:px-6" do
          div do
            link(Home::Index, class: "text-white ml-6 md:ml-0 mr-10 self-center") do
              img src: asset("images/logo.png"), class: "h-8 inline", alt: "Lucky Logo"
            end
          end
          main_navigation
        end
      end
    end
  end

  private def main_navigation
    small_screen_menu_button
    nav_and_search
  end

  private def nav_and_search
    nav id: "nav-links", class: "hidden w-full flex-grow md:flex md:flex-grow-0 md:w-auto mt-6 md:mt-0 justify-between items-center font-semibold" do
      nav_links
      docsearch_input
    end
  end

  private def small_screen_menu_button
    div class: "block md:hidden" do
      button id: "menu-btn", class: "flex items-center mr-5 px-3 py-2 border rounded text-teal-lighter border-teal-light hover:text-white hover:border-white" do
        tag "svg", class: "fill-current h-3 w-3", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg" do
          title "Menu"
          tag "path", d: "M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z"
        end
      end

      toggle_menu_js
    end
  end

  private def toggle_menu_js
    script do
      raw <<-JS
      document.getElementById("menu-btn").addEventListener("click", function() {
        document.getElementById("nav-links").classList.toggle("hidden");
      });
      JS
    end
  end

  private def nav_links
    nav_link("Guides", Guides::GettingStarted::Installing.path)
    nav_link("Learn", Learn::Index.path)
    nav_link("Blog", Blog::Index.path)
    nav_link("Team", Team::Index.path)
    nav_link("Chat", Chat::Index.path, target: "_blank")
    nav_link("GitHub", "https://github.com/luckyframework/lucky", target: "_blank")
  end

  private def docsearch_input
    div class: "mx-5 md:m-0 header-search" do
      div id: "docsearch"
    end
  end

  private def nav_link(title, href, active : Bool = false, target : String = "_self")
    a title,
      href: href,
      target: target,
      class: "uppercase block md:inline-block font-bold text-white tracking-wider no-underline md:mr-4 px-8 py-5 md:px-4 md:py-8 text-sm hover:bg-blue-darker hover:text-white"
  end
end
