class Shared::Footer < BaseComponent
  def render
    footer class: "py-4" do
      div class: "container mx-auto" do
        div class: "flex flex-wrap justify-center md:justify-between items-center md:px-6" do
          div class: "flex flex-col items-center md:flex-row" do
            footer_link("Code of Conduct", "https://github.com/luckyframework/lucky/blob/master/CODE_OF_CONDUCT.md")
            footer_link("Contributors", "https://github.com/luckyframework/lucky/graphs/contributors")
          end
          div class: "flex flex-wrap md:flex-no-wrap justify-between items-center py-4 md:py-0 md:px-6" do
            footer_icon("https://github.com/luckyframework/lucky", "icons/github.svg", "Github")
            footer_icon("https://twitter.com/luckyframework", "icons/twitter.svg", "Twitter")
            footer_icon("https://gitter.im/luckyframework/Lobby", "icons/gitter.svg", "Gitter")
          end
        end
      end
    end
  end

  private def footer_link(title, url)
    a title, class: "inline-block text-grey-darkest no-underline md:mr-2 md:mb-2 px-2 py-2 hover:text-black ", href: url
  end

  macro footer_icon(url, icon_path, alt_desc)
    link({{ url }}, class: "ml-6 md:ml-0 mr-10 self-center") do
      img src: asset({{ icon_path }}), class: "h-8", alt: {{ alt_desc }}
    end
  end
end
