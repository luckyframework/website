class Guides::Sidebar < BaseComponent
  needs current_guide : GuideAction.class

  def render
    div class: "text-black md:absolute top-0 left-0 bg-white md:rounded-lg shadow md:shadow-lg w-full md:w-sidebar md:mt-5 md:ml-2 pb-3 md:mb-10" do
      ul class: "p-0" do
        li "Lucky v#{LuckyCliVersion.current_version}", class: "text-sm text-grey-dark tracking-wider border-b border-grey-light py-3 mt-3 px-8 md:ml-8 md:pl-0 mb-4"
        GuidesList.categories.each do |category|
          li do
            if category.active?(@current_guide)
              render_active_category_and_guides(category)
            else
              link category.title, category.guides.first, class: "block text-sm tracking-wider text-grey-darker no-underline pl-8 py-3 hover:underline hover:text-blue-dark"
            end
          end
        end
      end
    end
  end

  private def render_active_category_and_guides(category : GuideCategory)
    div class: "block pb-3 bg-grey-lighter border-t border-b border-grey shadow-inner" do
      span category.title, class: "pl-8 py-3 mb-2 block bold text-sm tracking-wider"
      category.guides.each do |guide|
        if guide == @current_guide
          link guide.title, guide, class: "block text-sm text-white no-underline pl-12 py-3 hover:underline #{active_class}"
        else
          link guide.title, guide, class: "block text-sm text-grey-darker no-underline pl-12 py-3 hover:underline hover:text-blue-dark"
        end
      end
    end
  end

  def active_class
    "text-white bg-teal text-shadow hover:no-underline hover:text-white"
  end
end
