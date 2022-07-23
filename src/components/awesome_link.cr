class AwesomeLink < BaseComponent
  enum Tags
    Crypto
    Adult # this link may contain content that is age restricted
  end

  needs text : String
  needs url : String
  needs description : String?
  needs tags : Array(Tags)?

  def render
    li do
      a class: "block hover:bg-gray-50", href: url, target: "_blank", data_confirm: confirmation_text do
        div class: "p-4 flex justify-between items-center" do
          section class: "truncate" do
            span text, class: "text-lucky-teal-blue text-lg font-medium"
            render_tags
            if description
              para description.to_s, class: "text-gray-400 truncate"
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

  private def render_tags
    (tags || [] of Tags).each do |tag|
      if tag.adult?
        span "Adult",
          class: "bg-red-500 text-white py-1 px-3 rounded text-xs ml-2",
          title: "This site may contain sensitive or age restricted content. Discretion is advised."
      else
        span tag.to_s,
          class: "bg-lucky-dark-green text-white py-1 px-3 rounded text-xs ml-2"
      end
    end
  end

  private def confirmation_text
    if tags.try(&.includes?(Tags::Adult))
      "Are you sure you want to visit #{text}? Discretion is advised"
    else
      ""
    end
  end
end
