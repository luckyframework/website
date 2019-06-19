class Guides::ShowPage < GuideLayout
  needs guide_file_path : String

  def content
    raw CustomMarkdownRenderer.render_to_html(@markdown)
  end
end
