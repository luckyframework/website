class Learn::Community::IndexPage < PageLayout
  def hero_content
    render_hero_content
  end

  def content
    # Discord chat, bluesky, maybe mention the t-shirt giveaway...
    div class: "py-16 container text-center" do
      h2 class: "text-xl font-semibold leading-7 text-gray-900 sm:text-2xl sm:truncate" do
        text "Coming soon..."
      end
    end
  end

  private def render_hero_content
    div class: "bg-lucky-teal-blue-gradient" do
      div class: "py-8 md:py-16 px-6 sm:px-10 mx-auto container text-center text-white" do
        div class: "mx-auto md:px-24 lg:px-32" do
          h1 class: "leading-normal text-blue-lightest font-light text-3xl md:text-4xl" do
            text "The Lucky Community"
          end

          para class: "text-blue-lighter lg:px-24 leading-loose mt-5 text-lg sm:text-xl" do
            text <<-TEXT
            Get to know the wonderful people that make this community so great!
            TEXT
          end
        end
      end
    end
  end
end
