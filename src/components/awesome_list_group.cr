class AwesomeListGroup < BaseComponent
  needs group_title : String

  def render
    div class: "bg-white rounded-lg w-full mb-5" do
      h2 group_title, class: "bg-gray-200 p-3 text-xl"
      ul class: "divide-y divide-gray-300 p-0" do
        yield
      end
    end
  end
end
