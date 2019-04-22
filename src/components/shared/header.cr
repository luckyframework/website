class Shared::Header < BaseComponent
  needs request : HTTP::Request

  def render
    header class: "antialiased text-grey-light shadow-inner-bottom bg-lucky-blue" do
      div class: "container mx-auto px-6" do
        div class: "flex justify-between items-center pt-5 pb-3 px-6" do
          main_navigation
        end
      end
    end
  end

  private def main_navigation
    nav class: "flex flex-wrap pt-2 font-semibold" do
      # link(Home::Index, class: "text-white mr-10 self-center") { mount Bloomlist::Logo.new }
      nav_link("Home", Home::Index, active: @request.resource == Home::Index.path)
      nav_link("Guides", "#")
      nav_link("Settings", "#")
    end
  end

  private def nav_link(title, href, active : Bool = false)
    link title, to: href, class: "uppercase font-semibold text-grey-light tracking-wide no-underline mr-4 mb-2 px-4 py-1 rounded-full text-sm hover:bg-black-20 hover:text-white #{active_class(active)}"
  end

  private def active_class(active)
    if active
      "text-white bg-white-opacity-25"
    end
  end
end
