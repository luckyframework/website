require "./html_autolink"

class CustomMarkdownRenderer < Markd::HTMLRenderer
  def self.render_to_html(content)
    html(content).lines.map do |line|
      if line.starts_with?("<h2>")
        add_anchor_to_heading("h2", line)
      elsif line.starts_with?("<h3>")
        add_anchor_to_heading("h3", line)
      else
        line
      end
    end.join("\n")
  end

  def self.add_anchor_to_heading(tag : String, heading_html : String) : String
    heading_without_wrapper_tag = heading_html
      .gsub("<#{tag}>", "")
      .gsub("</#{tag}>", "")
    anchor = GenerateHeadingAnchor.new(heading_without_wrapper_tag).call

    <<-HTML
    <#{tag} id="#{anchor}">
      <a href="##{anchor}" class="md-anchor">#</a>
      #{heading_without_wrapper_tag}
    </#{tag}>
    HTML
  end

  def self.html(content)
    options = Markd::Options.new(smart: true)
    document = Markd::Parser.parse(content, options)
    html = new(options).render(document)
    HtmlAutolink.new(html).call
  end
end
