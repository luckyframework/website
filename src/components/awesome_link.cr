class AwesomeLink < BaseComponent
  needs text : String
  needs url : String
  needs description : String?

  def render
    li class: "hover:bg-gray-50 cursor-pointer" do
      a class: "block p-4 flex justify-between", href: url, target: "_blank" do
        div do
          span text, class: "text-lucky-teal-blue text-lg"
          if description
            para description.to_s, class: "text-gray-400"
          end
        end
        span aria_hidden: "true", class: "pointer-events-none text-gray-300" do
          tag "svg", class: "h-6 w-6", fill: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg" do
            tag "path", d: "M20 4h1a1 1 0 00-1-1v1zm-1 12a1 1 0 102 0h-2zM8 3a1 1 0 000 2V3zM3.293 19.293a1 1 0 101.414 1.414l-1.414-1.414zM19 4v12h2V4h-2zm1-1H8v2h12V3zm-.707.293l-16 16 1.414 1.414 16-16-1.414-1.414z"
          end
        end
      end
    end
  end
end
