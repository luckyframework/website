class Learn::IndexPage < PageLayout
  def hero_content
    render_hero_content
  end

  def content
    div class: "md:-mt-12 md:rounded-lg bg-gray-200 overflow-hidden shadow divide-y divide-gray-200 sm:divide-y-0 sm:grid sm:grid-cols-2 sm:gap-px" do
      div class: "md:rounded-tl-lg md:rounded-tr-lg sm:rounded-tr-none relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500" do
        div do
          span class: "rounded-lg inline-flex p-3 bg-green-50 text-green-700 ring-4 ring-white" do
            tag "svg", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: Guides::GettingStarted::Installing.path do
              span aria_hidden: "true", class: "absolute inset-0"
              text "Guides"
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text "From setting up your first app to writing advanced database queries, the official guides have you covered."
          end
        end
        span aria_hidden: "true", class: "pointer-events-none absolute top-6 right-6 text-gray-300 group-hover:text-gray-400" do
          tag "svg", class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
            tag "path", d: "M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z"
          end
        end
      end
      div class: "sm:rounded-tr-lg relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500" do
        div do
          span class: "rounded-lg inline-flex p-3 bg-purple-50 text-purple-700 ring-4 ring-white" do
            tag "svg", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M12 14l9-5-9-5-9 5 9 5z"
              tag "path", d: "M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z"
              tag "path", d: "M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: Learn::Tutorial::Overview.path do
              span aria_hidden: "true", class: "absolute inset-0"
              text "Tutorial"
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text "Get started with your very first Lucky Application! We will walk you through building a simple application step by step to give you a feel for the framework."
          end
        end
        span aria_hidden: "true", class: "pointer-events-none absolute top-6 right-6 text-gray-300 group-hover:text-gray-400" do
          tag "svg", class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
            tag "path", d: "M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z"
          end
        end
      end
      div class: "relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500" do
        div do
          span class: "rounded-lg inline-flex p-3 bg-light-blue-50 text-light-blue-700 ring-4 ring-white" do
            tag "svg", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: "https://luckycasts.com/", target: "_blank" do
              span aria_hidden: "true", class: "absolute inset-0"
              text "Screencasts"
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text "Provided by the amazing LuckyCasts. You'll find some amazing free video content, as well as some Pro level videos to keep you learning."
          end
        end
        span aria_hidden: "true", class: "pointer-events-none absolute top-6 right-6 text-gray-300 group-hover:text-gray-400" do
          tag "svg", class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
            tag "path", d: "M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z"
          end
        end
      end
      div class: "relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500" do
        div do
          span class: "rounded-lg inline-flex p-3 bg-yellow-50 text-yellow-700 ring-4 ring-white" do
            tag "svg", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: "https://github.com/andrewmcodes/awesome-lucky#readme", target: "_blank" do
              span aria_hidden: "true", class: "absolute inset-0"
              text "Awesome Lucky"
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text "Awesome Lists are lists of very helpful resources within a particular community. This is our list for Awesome Lucky originally provided by the Awesome @andrewmcodes."
          end
        end
        span aria_hidden: "true", class: "pointer-events-none absolute top-6 right-6 text-gray-300 group-hover:text-gray-400" do
          tag "svg", class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
            tag "path", d: "M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z"
          end
        end
      end
      div class: "sm:rounded-bl-lg relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500" do
        div do
          span class: "rounded-lg inline-flex p-3 bg-rose-50 text-rose-700 ring-4 ring-white" do
            tag "svg", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: Learn::Ecosystem::Index.path do
              span aria_hidden: "true", class: "absolute inset-0"
              text "Ecosystem"
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text "The Lucky framework comes out of the box with a wide array of tools. This section will explain each of the shards that make up Lucky, including the API References to each component."
          end
        end
        span aria_hidden: "true", class: "pointer-events-none absolute top-6 right-6 text-gray-300 group-hover:text-gray-400" do
          tag "svg", class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
            tag "path", d: "M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z"
          end
        end
      end
      div class: "md:rounded-bl-lg md:rounded-br-lg sm:rounded-bl-none relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500" do
        div do
          span class: "rounded-lg inline-flex p-3 bg-indigo-50 text-indigo-700 ring-4 ring-white" do
            tag "svg", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: Learn::Community::Index.path do
              span aria_hidden: "true", class: "absolute inset-0"
              text "Community"
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text "We love the Lucky community, and we want to show them off to you! Make yourselves at home."
          end
        end
        span aria_hidden: "true", class: "pointer-events-none absolute top-6 right-6 text-gray-300 group-hover:text-gray-400" do
          tag "svg", class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
            tag "path", d: "M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z"
          end
        end
      end
    end
  end

  private def render_hero_content
    div class: "bg-lucky-teal-blue-gradient" do
      div class: "py-8 md:py-16 px-6 sm:px-10 mx-auto container text-center text-white" do
        div class: "mx-auto md:px-24 lg:px-32" do
          h1 class: "leading-normal text-blue-lightest font-light text-3xl md:text-4xl" do
            text "Welcome to Lucky"
          end

          para class: "text-blue-lighter lg:px-24 leading-loose mt-5 text-lg sm:text-xl" do
            # TODO - Revise this with some better text
            text <<-TEXT
            Check out some of these resources to get up and running!
            TEXT
          end
        end
      end
    end
  end

  private def content_block(title : String, link_location : String, body : String)
    div class: "p-4" do
      a title, href: link_location, class: "font-normal text-2xl text-teal-dark block mb-5"
      para body
      a "View", href: link_location, class: "btn btn--blue w-full sm:w-auto sm:mr-5"
    end
  end
end
