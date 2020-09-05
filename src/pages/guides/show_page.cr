class Guides::ShowPage
  include Lucky::HTMLPage

  needs title : String
  needs guide_action : GuideAction.class
  needs guide_file_path : String
  needs markdown : String

  def page_title
    title
  end

  def render
    html_doctype

    html lang: "en" do
      mount Shared::LayoutHead, seo: SEO.new(page_title), context: @context

      body class: "font-sans text-grey-darkest leading-tight bg-grey-lighter" do
        mount Shared::Header, @context.request
        middle_section
        guide_content
      end

      mount Shared::Footer
    end
  end

  def middle_section
    div class: "md:bg-lucky-teal-blue-gradient" do
      div class: "flex relative md:py-8 md:pr-10 container mx-auto text-white" do
        table_of_contents
        mount Guides::Sidebar, guide_action
      end
    end
  end

  def guide_content
    div class: "flex flex-col container mx-auto" do
      section class: "md:pl-sidebar" do
        # Must be a section for Algolia docsearch to index it
        #
        # https://github.com/algolia/docsearch-configs/blob/master/configs/luckyframework.json
        section class: "mb-16 px-5 md:px-0 markdown-content container" do
          raw CustomMarkdownRenderer.render_to_html(markdown)
        end

        next_button
        edit_guide_on_github
      end
    end
  end

  def edit_guide_on_github
    div class: "rounded bg-grey-light p-5 mb-12" do
      text "See a problem? Have an idea for improvement?"
      text " "
      a "Edit this page on GitHub", href: GitHubPath.for_file(guide_file_path),
        target: "_blank",
        class: "text-teal-dark hover:text-teal-darker underline"
    end
  end

  def next_button
    next_guide = GuidesList.next_guide(current_guide: guide_action)

    if next_guide
      div class: "mb-12 pt-12 pb-6 border-t" do
        link to: next_guide, class: "flex flex-col text-right pr-6 no-underline group underline" do
          span "Next guide →", class: "font-bold text-grey-dark text-sm tracking-wider uppercase pb-2"
          span next_guide.title, class: "font-bold underline text-xl m-0 text-teal-dark group-hover:text-teal-darkest"
        end
      end
    end
  end

  def table_of_contents
    div class: "hidden md:block mt-5 pl-sidebar #{algolia_docsearch_class}" do
      h1 title, class: "font-normal text-3xl text-white text-shadow mb-6 tracking-wide"
      ul class: "p-0 text-shadow text-lg mb-4 #{guide_sections.size > 6 && "split-columns"}" do
        guide_sections.each do |section|
          li do
            a href: "##{GenerateHeadingAnchor.new(section).call}", class: "text-white block py-1 no-underline " do
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
    markdown.split("\n").select(&.starts_with?("## ")).map(&.gsub("## ", ""))
  end
end
