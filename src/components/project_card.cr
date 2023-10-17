class ProjectCard < BaseComponent
  needs name : String
  needs description : String
  needs slug : String

  def render
    li class: "col-span-1 bg-white rounded-lg shadow divide-y divide-gray-200" do
      div class: "w-full flex items-center justify-between p-6 space-x-6" do
        div class: "flex-1 truncate" do
          div class: "flex items-center space-x-3" do
            h3 name, class: "text-gray-900 text-sm font-medium truncate"
            # Optional tags
            # span "Required", class: "flex-shrink-0 inline-block px-2 py-0.5 text-green-800 text-xs font-medium bg-green-100 rounded-full"
          end
          para description, class: "mt-1 text-gray-500 text-sm truncate"
        end
        img src: asset("images/lucky-icon.png"), class: "w-10 h-10 flex-shrink-0"
      end
      div do
        div class: "-mt-px flex divide-x divide-gray-200" do
          div class: "w-0 flex-1 flex" do
            a href: "https://crystaldoc.info/github/luckyframework/#{slug}/", class: "relative -mr-px w-0 flex-1 inline-flex items-center justify-center py-4 text-sm text-gray-700 font-medium border border-transparent rounded-bl-lg hover:text-gray-500" do
              tag "svg", class: "h-5 w-5", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg" do
                tag "path", d: "M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2h-1.528A6 6 0 004 9.528V4z"
                tag "path", clip_rule: "evenodd", d: "M8 10a4 4 0 00-3.446 6.032l-1.261 1.26a1 1 0 101.414 1.415l1.261-1.261A4 4 0 108 10zm-2 4a2 2 0 114 0 2 2 0 01-4 0z", fill_rule: "evenodd"
              end
              span "API Reference", class: "ml-3"
            end
          end
          div class: "-ml-px w-0 flex-1 flex" do
            a href: "https://github.com/luckyframework/#{slug}", class: "relative w-0 flex-1 inline-flex items-center justify-center py-4 text-sm text-gray-700 font-medium border border-transparent rounded-br-lg hover:text-gray-500" do
              tag "svg", class: "h-5 w-5", fill: "currentColor", viewBox: "0 0 20 20", xmlns: "http://www.w3.org/2000/svg" do
                tag "path", clip_rule: "evenodd", d: "M12.316 3.051a1 1 0 01.633 1.265l-4 12a1 1 0 11-1.898-.632l4-12a1 1 0 011.265-.633zM5.707 6.293a1 1 0 010 1.414L3.414 10l2.293 2.293a1 1 0 11-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0zm8.586 0a1 1 0 011.414 0l3 3a1 1 0 010 1.414l-3 3a1 1 0 11-1.414-1.414L16.586 10l-2.293-2.293a1 1 0 010-1.414z", fill_rule: "evenodd"
              end
              span "View Source", class: "ml-3"
            end
          end
        end
      end
    end
  end
end
