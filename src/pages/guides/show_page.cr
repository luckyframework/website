class Guides::ShowPage < GuideLayout
  def content
    options = Markd::Options.new(smart: true)
    raw Markd.to_html(@markdown, options)
  end
end
