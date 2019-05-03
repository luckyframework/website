class Guides::ShowPage < GuideLayout
  needs markdown : String
  needs title : String

  def content
    raw Markdown.to_html(@markdown)
  end
end
