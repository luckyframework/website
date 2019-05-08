class Guides::ShowPage < GuideLayout
  def content
    raw CustomMarkdownRenderer.render_to_html(@markdown)
  end
end
