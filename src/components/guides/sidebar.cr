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
        if guide.external_link?
          a href: guide.external_url, target: "_blank", class: "flex flex-row text-sm text-grey-darker no-underline pl-12 py-3 hover:underline hover:text-blue-dark" do
            span guide.title, class: "mr-2"
            span do
              external_link_svg_tag
            end
          end
        elsif guide == @current_guide
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

  def external_link_svg_tag
    tag "svg", height: "24px", version: "1.1", viewbox: "0 0 24 24", width: "24px", xlink: "http://www.w3.org/1999/xlink", xmlns: "http://www.w3.org/2000/svg" do
      tag "g", fill: "none", fill_rule: "evenodd", id: "Page-1", stroke: "none", stroke_width: "1" do
        tag "g", id: "External-Link" do
          tag "rect", " ", fill_rule: "nonzero", height: "24", id: "Rectangle", width: "24", x: "0", y: "0"
          tag "path", " ", d: "M20,12 L20,18 C20,19.1046 19.1046,20 18,20 L6,20 C4.89543,20 4,19.1046 4,18 L4,6 C4,4.89543 4.89543,4 6,4 L12,4", id: "Path", stroke: "#12283a", stroke_linecap: "round", stroke_width: "2"
          tag "path", " ", d: "M16,4 L19,4 C19.5523,4 20,4.44772 20,5 L20,8", id: "Path", stroke: "#12283a", stroke_linecap: "round", stroke_width: "2"
          tag "line", " ", id: "Path", stroke: "#12283a", stroke_linecap: "round", stroke_width: "2", x1: "11", x2: "19", y1: "13", y2: "5"
        end
      end
    end
  end
end
