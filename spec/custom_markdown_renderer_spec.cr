require "./spec_helper"

describe CustomMarkdownRenderer do
  it "creates an anchor for headings" do
    content = <<-MD
    ## Heading with anchor
    MD

    parsed = parse(content)

    parsed.should contain <<-HTML
    <h2 id="heading-with-anchor">Heading with anchor</h2>
    HTML
    parsed.should contain <<-HTML
    <a href="#heading-with-anchor" class="md-anchor">#</a>
    HTML
  end
end

private def parse(content)
  options = Markd::Options.new(smart: true)
  document = Markd::Parser.parse(content, options)
  CustomMarkdownRenderer.new(options).render(document)
end
