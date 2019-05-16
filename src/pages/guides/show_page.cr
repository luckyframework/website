class Guides::ShowPage < GuideLayout
  needs guide_file_path : String

  def content
    raw CustomMarkdownRenderer.render_to_html(@markdown)

    div class: "rounded bg-grey-light p-5 mt-12" do
      text "See a problem? Have an idea for improvement?"
      text " "
      link "Edit this page on GitHub", GitHubPath.for_file(@guide_file_path), target: "_blank"
    end
  end
end
