class Team::IndexPage < PageLayout
  record Member, fullname : String, avatar : String, title : String, github_link : String, mastodon_link : String?

  def team_members
    members = [] of Member
    members << Member.new("Paul Smith", "https://avatars.githubusercontent.com/u/22394?v=4", "Creator", "https://github.com/paulcsmith", nil)
    members << Member.new("Michael Wagner", "https://avatars.githubusercontent.com/u/13472976?v=4", "Core", "https://github.com/mdwagner", "https://mindly.social/@chocolate42")
    members
  end

  def content
    div class: "pt-16 pb-32" do
      div class: "mx-auto max-w-7xl px-6 text-center lg:px-8" do
        div class: "mx-auto max-w-2xl" do
          h2 "Meet our team", class: "text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl"
          para "We're a dynamic group of individuals who are passionate about what we do.", class: "mt-4 text-lg leading-8 text-gray-600"
        end
        ul class: "mx-auto mt-20 grid max-w-2xl grid-cols-1 gap-x-8 gap-y-16 sm:grid-cols-2 lg:mx-0 lg:max-w-none lg:grid-cols-3", role: "list" do
          team_members.each do |member|
            li do
              img alt: "", class: "mx-auto h-56 w-56 rounded-full", src: member.avatar
              h3 member.fullname, class: "mt-6 text-base font-semibold leading-7 tracking-tight text-gray-900"
              para member.title, class: "text-sm leading-6 text-gray-600"
              ul class: "mt-6 flex justify-center px-6 gap-x-6", role: "list" do
                li do
                  render_github_icon_link(member.github_link)
                end
                if mastodon_link = member.mastodon_link
                  li do
                    render_mastodon_icon_link(mastodon_link)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  #def hero_content
    #div class: "bg-lucky-teal-blue-gradient" do
      #div class: "py-8 md:py-16 px-6 sm:px-10 mx-auto container text-center text-white" do
        #div class: "mx-auto md:px-24 lg:px-32" do
          #h1 class: "leading-normal text-blue-lightest font-light text-3xl md:text-4xl" do
            #text "Meet our team"
          #end
        #end
      #end
    #end
  #end

  private def render_github_icon_link(link : String)
    a class: "text-gray-400 hover:text-gray-500", href: link do
      span "GitHub", class: "sr-only"
      tag "svg", aria_hidden: "true", class: "h-5 w-5", fill: "currentColor", viewbox: "0 0 496 512", xmlns: "http://www.w3.org/2000/svg" do
        tag "path", d: "M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6 0-2 2.3-3.6 5.2-3.6 3-.3 5.6 1.3 5.6 3.6zm-31.1-4.5c-.7 2 1.3 4.3 4.3 4.9 2.6 1 5.6 0 6.2-2s-1.3-4.3-4.3-5.2c-2.6-.7-5.5.3-6.2 2.3zm44.2-1.7c-2.9.7-4.9 2.6-4.6 4.9.3 2 2.9 3.3 5.9 2.6 2.9-.7 4.9-2.6 4.6-4.6-.3-1.9-3-3.2-5.9-2.9zM244.8 8C106.1 8 0 113.3 0 252c0 110.9 69.8 205.8 169.5 239.2 12.8 2.3 17.3-5.6 17.3-12.1 0-6.2-.3-40.4-.3-61.4 0 0-70 15-84.7-29.8 0 0-11.4-29.1-27.8-36.6 0 0-22.9-15.7 1.6-15.4 0 0 24.9 2 38.6 25.8 21.9 38.6 58.6 27.5 72.9 20.9 2.3-16 8.8-27.1 16-33.7-55.9-6.2-112.3-14.3-112.3-110.5 0-27.5 7.6-41.3 23.6-58.9-2.6-6.5-11.1-33.3 2.6-67.9 20.9-6.5 69 27 69 27 20-5.6 41.5-8.5 62.8-8.5s42.8 2.9 62.8 8.5c0 0 48.1-33.6 69-27 13.7 34.7 5.2 61.4 2.6 67.9 16 17.7 25.8 31.5 25.8 58.9 0 96.5-58.9 104.2-114.8 110.5 9.2 7.9 17 22.9 17 46.4 0 33.7-.3 75.4-.3 83.6 0 6.5 4.6 14.4 17.3 12.1C428.2 457.8 496 362.9 496 252 496 113.3 383.5 8 244.8 8zM97.2 352.9c-1.3 1-1 3.3.7 5.2 1.6 1.6 3.9 2.3 5.2 1 1.3-1 1-3.3-.7-5.2-1.6-1.6-3.9-2.3-5.2-1zm-10.8-8.1c-.7 1.3.3 2.9 2.3 3.9 1.6 1 3.6.7 4.3-.7.7-1.3-.3-2.9-2.3-3.9-2-.6-3.6-.3-4.3.7zm32.4 35.6c-1.6 1.3-1 4.3 1.3 6.2 2.3 2.3 5.2 2.6 6.5 1 1.3-1.3.7-4.3-1.3-6.2-2.2-2.3-5.2-2.6-6.5-1zm-11.4-14.7c-1.6 1-1.6 3.6 0 5.9 1.6 2.3 4.3 3.3 5.6 2.3 1.6-1.3 1.6-3.9 0-6.2-1.4-2.3-4-3.3-5.6-2z"
      end
    end
  end

  private def render_mastodon_icon_link(link : String)
    a class: "text-gray-400 hover:text-gray-500", href: link do
      span "Mastodon", class: "sr-only"
      tag "svg", aria_hidden: "true", class: "h-5 w-5", fill: "currentColor", viewbox: "0 0 448 512", xmlns: "http://www.w3.org/2000/svg" do
        tag "path", d: "M433 179.11c0-97.2-63.71-125.7-63.71-125.7-62.52-28.7-228.56-28.4-290.48 0 0 0-63.72 28.5-63.72 125.7 0 115.7-6.6 259.4 105.63 289.1 40.51 10.7 75.32 13 103.33 11.4 50.81-2.8 79.32-18.1 79.32-18.1l-1.7-36.9s-36.31 11.4-77.12 10.1c-40.41-1.4-83-4.4-89.63-54a102.54 102.54 0 0 1-.9-13.9c85.63 20.9 158.65 9.1 178.75 6.7 56.12-6.7 105-41.3 111.23-72.9 9.8-49.8 9-121.5 9-121.5zm-75.12 125.2h-46.63v-114.2c0-49.7-64-51.6-64 6.9v62.5h-46.33V197c0-58.5-64-56.6-64-6.9v114.2H90.19c0-122.1-5.2-147.9 18.41-175 25.9-28.9 79.82-30.8 103.83 6.1l11.6 19.5 11.6-19.5c24.11-37.1 78.12-34.8 103.83-6.1 23.71 27.3 18.4 53 18.4 175z"
      end
    end
  end
end
