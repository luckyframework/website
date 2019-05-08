class Guides::ShowPage < GuideLayout
  def content
    raw rendered_markdown
  end

  def rendered_markdown
    options = Markd::Options.new(smart: true)
    document = Markd::Parser.parse(@markdown, options)
    CustomRenderer.new(options).render(document)
  end
end

class CustomRenderer < Markd::HTMLRenderer
  def test
  end
end
