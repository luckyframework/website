abstract class GuideLayout
  include Lucky::HTMLPage

  abstract def content
  abstract def page_title

  needs title : String
  needs guide_action : GuideAction.class
  needs markdown : String

  def page_title
    @title
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead.new(page_title: page_title, context: @context)

      body class: "font-sans text-grey-darkest leading-tight bg-grey-lighter" do
        mount Shared::Header.new(@context.request)
        middle_section
        guide_content
      end
    end
  end

  def middle_section
    div class: "md:bg-lucky-teal-blue-gradient" do
      div class: "flex relative md:py-8 md:pr-10 container mx-auto text-white" do
        table_of_contents
        mount Guides::Sidebar.new(@guide_action)
      end
    end
  end

  def guide_content
    div class: "flex container mx-auto" do
      # Must be a section for Algolia docsearch to index it
      #
      # https://github.com/algolia/docsearch-configs/blob/master/configs/luckyframework.json
      section class: "mb-24 px-5 md:px-0 md:pl-sidebar markdown-content container" do
        content
      end
    end
  end

  def table_of_contents
    div class: "hidden md:block mt-5 pl-sidebar #{algolia_docsearch_class}" do
      h1 @title, class: "font-normal font-xl text-white text-shadow mb-6 tracking-medium"
      ul class: "list-reset text-shadow text-lg mb-4 #{guide_sections.size > 6 && "split-columns"}" do
        guide_sections.each do |section|
          li do
            link "##{GenerateHeadingAnchor.new(section).call}", class: "text-white block py-1 no-underline " do
              span "#", class: "text-blue-lighter mr-2 hover:no-underline"
              span section, class: "border-b border-blue-light mr-3 hover:border-white"
            end
          end
        end
      end
    end
  end

  # https://github.com/algolia/docsearch-configs/blob/master/configs/luckyframework.json
  #
  # Algolia looks for an h1 in this class to figure out the top level heading
  private def algolia_docsearch_class : String
    "page-intro"
  end

  def guide_sections
    @markdown.split("\n").select(&.starts_with?("## ")).map(&.gsub("## ", ""))
  end
end
