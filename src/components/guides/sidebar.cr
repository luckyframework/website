class GuideCategory
  getter title, guides

  def initialize(@title : String, @guides : Array(GuideAction.class))
  end

  def active?(guide_action : GuideAction.class)
    guides.includes?(guide_action)
  end
end

class Guides::Sidebar < BaseComponent
  needs current_guide : GuideAction.class

  @categories : Array(GuideCategory)

  private getter categories = [
    GuideCategory.new("Basics", [Guides::Basics::Installing] of GuideAction.class),
  ]

  def render
    div class: "text-black absolute pin-t pin-l bg-white rounded-lg shadow-lg w-sidebar mt-5 ml-2 pb-3 mb-10" do
      ul class: "list-reset" do
        li "All Guides", class: "uppercase text-sm text-grey-dark tracking-wide border-b border-grey-light py-3 mt-3 ml-8 mb-4"
        categories.each do |category|
          li do
            if category.active?(@current_guide)
              link category.title, "#", class: "block text-sm tracking-wide text-grey-darker no-underline pl-8 py-3 hover:bg-grey-lighter hover:underline #{active_class}"
            else
              link category.title, "#", class: "block text-sm tracking-wide text-grey-darker no-underline pl-8 py-3 hover:bg-grey-lighter hover:underline hover:text-blue-dark"
            end
          end
        end
      end
    end
  end

  def wut
  end

  def active_class
    "text-white bg-lucky-teal-blue text-shadow hover:bg-lucky-teal-blue hover:no-underline hover:text-white"
  end
end
