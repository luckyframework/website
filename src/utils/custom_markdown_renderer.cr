require "./html_autolink"

class CustomMarkdownRenderer < Markd::HTMLRenderer
  def self.render_to_html(content)
    html(content).lines.map do |line|
      if line.starts_with?("<h2>")
        add_anchor_to_heading(line)
      else
        line
      end
    end.join("\n")
  end

  def self.add_anchor_to_heading(heading_html : String) : String
    heading_without_html = heading_html
      .gsub("<h2>", "")
      .gsub("</h2>", "")
    anchor = GenerateHeadingAnchor.new(heading_without_html).call

    <<-HTML
    <h2 id="#{anchor}">
      <a href="##{anchor}" class="md-anchor">#</a>
      #{heading_without_html}
    </h2>
    HTML
  end

  def self.html(content)
    options = Markd::Options.new(smart: true)
    document = Markd::Parser.parse(content, options)
    html = new(options).render(document)
    HtmlAutolink.new(html).call
  end
end
