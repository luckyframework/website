class Shared::Footer < BaseComponent
  def render
    div class: "container mx-auto px-12 pb-8 flex flex-row justify-between" do
      div class: "-mx-2 mb-2" do
        footer_link("Pricing")
        footer_link("Support")
        footer_link("Terms")
      end
      div do
        para "© 2019 Bloomlist", class: "text-sm text-grey-dark"
      end
    end
  end

  private def footer_link(title)
    a title, class: "inline-block text-grey-darkest no-underline mr-2 mb-2 px-2 py-2 rounded hover:bg-grey-light hover:text-black ", href: "#"
  end
end
