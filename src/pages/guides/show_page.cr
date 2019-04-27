class Guides::ShowPage < GuideLayout
  needs markdown : String

  def content
    raw Markdown.to_html(@markdown)
  end
end
