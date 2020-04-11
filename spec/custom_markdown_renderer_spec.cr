require "./spec_helper"

describe CustomMarkdownRenderer do
  it "creates an anchor for headings" do
    content = <<-MD
    ## Heading with anchor

    Should remain unmodified

    ### Subheading with _anchor_
    MD

    parsed = parse(content)

    parsed.should contain <<-HTML
    <h2 id="heading-with-anchor">
      <a href="#heading-with-anchor" class="md-anchor">#</a>
      Heading with anchor
    </h2>
    HTML

    parsed.should contain <<-HTML
    <h3 id="subheading-with-anchor">
      <a href="#subheading-with-anchor" class="md-anchor">#</a>
      Subheading with <em>anchor</em>
    </h3>
    HTML

    parsed.should contain "Should remain unmodified"
  end
end

private def parse(content : String)
  CustomMarkdownRenderer.render_to_html(content)
end
