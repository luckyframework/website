class AwesomeLink < BaseComponent
  needs text : String
  needs url : String
  needs description : String?

  def render
    li class: "hover:bg-gray-50 cursor-pointer" do
      a class: "block p-4", href: url, target: "_blank" do
        span text, class: ""
        if description
          nbsp
          text "—"
          nbsp
          text description.to_s
        end
      end
    end
  end
end
