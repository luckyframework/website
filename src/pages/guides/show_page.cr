class Guides::ShowPage < GuideLayout
  needs markdown : String

  def content
    options = Markd::Options.new(smart: true)
    raw Markd.to_html(@markdown, options)
  end
end
