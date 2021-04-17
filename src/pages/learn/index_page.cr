class Learn::IndexPage < PageLayout
  def hero_content
    render_hero_content
  end

  def content
    div class: "-mt-12 rounded-lg bg-gray-200 overflow-hidden shadow divide-y divide-gray-200 sm:divide-y-0 sm:grid sm:grid-cols-2 sm:gap-px" do
      div class: "rounded-tl-lg rounded-tr-lg sm:rounded-tr-none relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500" do
        div do
          span class: "rounded-lg inline-flex p-3 bg-teal-50 text-teal-700 ring-4 ring-white" do
            tag "svg", aria_hidden: "true", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: "#" do
              span aria_hidden: "true", class: "absolute inset-0"
              text " Request time off "
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text " Doloribus dolores nostrum quia qui natus officia quod et dolorem. Sit repellendus qui ut at blanditiis et quo et molestiae. "
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
            tag "svg", aria_hidden: "true", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: "#" do
              span aria_hidden: "true", class: "absolute inset-0"
              text " Benefits "
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text " Doloribus dolores nostrum quia qui natus officia quod et dolorem. Sit repellendus qui ut at blanditiis et quo et molestiae. "
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
            tag "svg", aria_hidden: "true", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: "#" do
              span aria_hidden: "true", class: "absolute inset-0"
              text " Schedule a one-on-one "
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text " Doloribus dolores nostrum quia qui natus officia quod et dolorem. Sit repellendus qui ut at blanditiis et quo et molestiae. "
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
            tag "svg", aria_hidden: "true", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: "#" do
              span aria_hidden: "true", class: "absolute inset-0"
              text " Payroll "
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text " Doloribus dolores nostrum quia qui natus officia quod et dolorem. Sit repellendus qui ut at blanditiis et quo et molestiae. "
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
            tag "svg", aria_hidden: "true", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M16 15v-1a4 4 0 00-4-4H8m0 0l3 3m-3-3l3-3m9 14V5a2 2 0 00-2-2H6a2 2 0 00-2 2v16l4-2 4 2 4-2 4 2z", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: "#" do
              span aria_hidden: "true", class: "absolute inset-0"
              text " Submit an expense "
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text " Doloribus dolores nostrum quia qui natus officia quod et dolorem. Sit repellendus qui ut at blanditiis et quo et molestiae. "
          end
        end
        span aria_hidden: "true", class: "pointer-events-none absolute top-6 right-6 text-gray-300 group-hover:text-gray-400" do
          tag "svg", class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
            tag "path", d: "M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z"
          end
        end
      end
      div class: "rounded-bl-lg rounded-br-lg sm:rounded-bl-none relative group bg-white p-6 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500" do
        div do
          span class: "rounded-lg inline-flex p-3 bg-indigo-50 text-indigo-700 ring-4 ring-white" do
            tag "svg", aria_hidden: "true", class: "h-6 w-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
              tag "path", d: "M12 14l9-5-9-5-9 5 9 5z"
              tag "path", d: "M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z"
              tag "path", d: "M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2"
            end
          end
        end
        div class: "mt-8" do
          h3 class: "text-lg font-medium" do
            a class: "focus:outline-none", href: "#" do
              span aria_hidden: "true", class: "absolute inset-0"
              text " Training "
            end
          end
          para class: "mt-2 text-sm text-gray-500" do
            text " Doloribus dolores nostrum quia qui natus officia quod et dolorem. Sit repellendus qui ut at blanditiis et quo et molestiae. "
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

  # TODO - Delete this after converting to TailwindUI format
  def jeremy_content
    div class: "grid grid-rows-3 grid-flow-col gap-4" do
      content_block "Guides", Guides::GettingStarted::Installing.path, <<-TEXT
      Morbi rutrum ante sed lacus condimentum, nec eleifend orci scelerisque. Proin sollicitudin metus ante, vel pretium ante tempus ac.
      Nunc tincidunt purus at vehicula auctor.
      TEXT
      content_block "Tutorial", Learn::Tutorial::Overview.path, <<-TEXT
      Maecenas urna mi, sollicitudin quis urna id, facilisis laoreet magna. Cras eget enim sollicitudin, feugiat augue ac,
      faucibus magna. Fusce est tellus, rutrum a est sed, tincidunt rutrum diam.
      TEXT
      content_block "Screencasts", "https://luckycasts.com/", <<-TEXT
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque viverra mauris vitae dui blandit dictum.
      Aenean feugiat diam ac cursus euismod. In efficitur velit nec tempus pulvinar.
      TEXT
      content_block "Awesome Lucky", Learn::AwesomeLucky::Index.path, <<-TEXT
      Nullam vel pulvinar libero. Aliquam vulputate elit mauris, ultrices elementum eros rhoncus eu.
      Proin consequat lacus ut odio consectetur, vitae dignissim tortor viverra.
      TEXT
      content_block "Ecosystem", Learn::Ecosystem::Index.path, <<-TEXT
      Nunc eu blandit dolor. Ut sodales velit nec quam tempor feugiat. Phasellus in ipsum non quam eleifend aliquet sed vitae ipsum.
      Donec accumsan dui quis cursus rhoncus.
      TEXT
      content_block "Community", Learn::Community::Index.path, <<-TEXT
      Aenean ullamcorper accumsan justo sit amet ultrices. Fusce dictum elit urna, at tincidunt ex egestas quis.
      Duis ut nisl efficitur, dictum sem varius, feugiat turpis.
      TEXT
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
