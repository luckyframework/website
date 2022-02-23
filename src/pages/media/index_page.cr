class Media::IndexPage < PageLayout
  def hero_content
    render_hero_content
  end

  def content
    div class: "p-16" do
      h1 "Assets", class: "text-2xl font-bold"

      h2 "Logo & Icon", class: "mt-8 text-xl font-semibold"

      div class: "mt-2 sm:flex items-center space-y-6 sm:space-y-0 sm:space-x-8" do
        a href: asset("media/lucky_logo.png"), download: "lucky_logo.png", class: logo_wrapper_classes do
          img src: asset("media/lucky_logo.png"), class: "p-4"
          small "Logo", class: "text-white absolute bottom-2 left-2"
        end

        a href: asset("media/lucky_icon.png"), download: "lucky_icon.png", class: logo_wrapper_classes do
          img src: asset("media/lucky_icon.png"), class: "p-4 h-24 w-24"
          small "Icon", class: "text-white absolute bottom-2 left-2"
        end
      end

      h2 "Colors", class: "mt-8 text-xl font-semibold"

      div class: "mt-2 sm:flex sm:items-center space-y-6 sm:space-y-0 sm:space-x-8" do
        render_color("Blue", "#031E37", "bg-lucky-blue")
        render_color("Teal Blue", "#1B92B3", "bg-lucky-teal-blue")
        render_color("Dark Green", "#37DE97", "bg-lucky-dark-green")
        render_color("Light Green", "#9DFF66", "bg-lucky-light-green")
      end

      hr class: "my-16"

      h1 "Guidelines", class: "text-2xl font-bold"

      h2 "What can you do with the Lucky logos and brand?", class: "mt-8 mb-4 text-xl font-semibold"
      ul class: "space-y-2" do
        render_allowed_list_item("Print them on any merchandise you want, as long as you don’t sell it.")
        render_allowed_list_item("Use them in presentations, papers and talks.")
        render_allowed_list_item("Use them to advertise something you’ve created with Lucky.")
        render_allowed_list_item("Use them in blog posts, articles or news about Lucky.")
        render_allowed_list_item("Use them for educational purposes, as long as it’s available for free.")
      end

      h2 "Don’t do these things with the Lucky logos and brand:", class: "mt-8 mb-4 text-xl font-semibold"
      ul class: "space-y-2" do
        render_disallowed_list_item("Change their colors, dimensions or add your own text.")
        render_disallowed_list_item("Sell Lucky artwork or merchandise without permission.")
        render_disallowed_list_item("Integrate your own logo with Lucky logos.")
        render_disallowed_list_item("Use the Lucky logos as your brand, company or app image.")
        render_disallowed_list_item("Use the logo in a way that could suggest sponsorship or endorsement by Lucky.")
      end

      h2 "Don’t hesitate to contact us if:", class: "mt-8 mb-4 text-xl font-semibold"
      ul class: "space-y-2" do
        render_contact_list_item("You want permission to sell Lucky merchandise.")
        render_contact_list_item("You want to use these logos for commercial purposes.")
        render_contact_list_item("You have questions about the use of Lucky brand and logos.")
      end
    end
  end

  private def render_contact_list_item(text : String)
    li class: "flex space-x-2" do
      tag "svg", class: "flex-shrink-0 h-5 w-5 text-gray-500", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg" do
        tag "path", clip_rule: "evenodd", d: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z", fill_rule: "evenodd"
      end

      para text
    end
  end

  private def render_allowed_list_item(text : String)
    li class: "flex space-x-2" do
      tag "svg", class: "flex-shrink-0 h-5 w-5 text-green-500", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg" do
        tag "path", clip_rule: "evenodd", d: "M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z", fill_rule: "evenodd"
      end

      para text
    end
  end

  private def render_disallowed_list_item(text : String)
    li class: "flex space-x-2" do
      tag "svg", class: "flex-shrink-0 h-5 w-5 text-red-500", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg" do
        tag "path", clip_rule: "evenodd", d: "M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z", fill_rule: "evenodd"
      end

      para text
    end
  end

  private def render_color(label : String, hex_color : String, tailwind_background : String)
    div class: "sm:text-center" do
      div class: "h-16 w-16 sm:mx-auto ring-2 ring-lucky-blue rounded-full #{tailwind_background}"
      para label, class: "mt-1 text-sm"
      para hex_color, class: "text-sm uppercase"
    end
  end

  private def logo_wrapper_classes
    "h-40 w-40 hover:ring-4 ring-lucky-teal-blue ring-inset relative flex items-center justify-center bg-lucky-blue"
  end

  private def render_hero_content
    div class: "bg-lucky-teal-blue-gradient" do
      div class: "py-8 md:py-16 px-6 sm:px-10 mx-auto text-center text-white" do
        div class: "mx-auto md:px-24 lg:px-32" do
          h1 class: "leading-normal text-blue-lightest font-light text-3xl md:text-4xl" do
            text "Media & Brand"
          end

          para class: "text-blue-lighter lg:px-24 leading-loose mt-5 text-lg sm:text-xl" do
            text <<-TEXT
            As our community continues to grow, we think it is important to have basic rules of thumb
            about how and for what purposes the Lucky brand can be used. These rules are largely inspired
            by the Crystal media guidelines set forth at
            TEXT

            text " "

            a "https://crystal-lang.org/media", class: "underline hover:text-blue-dark", href: "https://crystal-lang.org/media", target: "_blank"

            text "."
          end
        end
      end
    end
  end
end
