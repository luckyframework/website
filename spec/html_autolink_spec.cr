require "./spec_helper"

describe HtmlAutolink do
  it "autolinks if there is a protocol" do
    content = %(http://example.com)

    parsed = autolink(content)

    parsed.should eq %(<a href="http://example.com">http://example.com</a>)
  end

  it "does not autolink already linked or URLs without protocol" do
    content = %(example.com)

    parsed = autolink(content)

    parsed.should eq %(example.com)
  end

  it "does not autolink if already linked" do
    content = %(<a href="#">http://alreadylinked.com</a>)

    parsed = autolink(content)

    parsed.should eq %(<a href="#">http://alreadylinked.com</a>)
  end

  it "does not autolink hrefs" do
    content = %(<a href="https://github.com/">Github</a>)

    parsed = autolink(content)

    parsed.should eq %(<a href="https://github.com/">Github</a>)
  end
end

private def autolink(content)
  HtmlAutolink.new(content).call
end
