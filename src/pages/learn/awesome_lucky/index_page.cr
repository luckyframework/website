class Learn::AwesomeLucky::IndexPage < PageLayout
  def hero_content
    render_hero_content
  end

  def content
    # https://github.com/andrewmcodes/awesome-lucky
    div class: "py-4 container text-center" do
      text "Coming soon..."
    end
  end

  private def render_hero_content
    div class: "bg-lucky-teal-blue-gradient" do
      div class: "py-8 md:py-16 px-6 sm:px-10 mx-auto container text-center text-white" do
        div class: "mx-auto md:px-24 lg:px-32" do
          h1 class: "leading-normal text-blue-lightest font-light text-3xl md:text-4xl" do
            text "Awesome Lucky"
          end

          para class: "text-blue-lighter lg:px-24 leading-loose mt-5 text-lg sm:text-xl" do
            text <<-TEXT
            A categorized community-driven collection of awesome Lucky libraries, tools, resources.
            TEXT
          end
        end
      end
    end
  end
end
