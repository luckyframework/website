class AwesomeListGroup < BaseComponent
  needs group_title : String

  def render(&)
    section class: "bg-white sm:rounded-lg shadow w-full mb-5 overflow-hidden" do
      h2 group_title, class: "bg-lucky-blue font-semibold text-gray-100 text-xl p-3"
      ul class: "divide-y divide-gray-300 p-0" do
        yield
      end
    end
  end
end
