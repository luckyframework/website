require "./html_autolink"

class CustomMarkdownRenderer
  COPY_ICON_SVG = File.read("public/assets/icons/copy.svg")
  TICK_ICON_SVG = File.read("public/assets/icons/tick.svg")

  def self.render_to_html(content : String) : String
    html(content).lines.map do |line|
      if line.starts_with?("<h2>")
        add_anchor_to_heading("h2", line)
      elsif line.starts_with?("<h3>")
        add_anchor_to_heading("h3", line)
      else
        line
      end
    end
      .join("\n")
      .gsub("</code></pre>", "</code><button class=\"copy-code-button\">#{COPY_ICON_SVG}</button></pre>") + copy_functionality_script
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

  def self.copy_functionality_script : String
    <<-HTML
      <script>
        document.addEventListener('click', function(event) {
          var button = event.target.closest('.copy-code-button');
          if (!button) return;
          var preElement = button.closest('pre');
          var codeBlock = preElement.querySelector('code');
          var textarea = document.createElement('textarea');
          textarea.value = codeBlock.textContent;
          document.body.appendChild(textarea);
          textarea.select();
          document.execCommand('copy');
          document.body.removeChild(textarea);
          button.innerHTML = '#{TICK_ICON_SVG}';
          setTimeout(() => {
            button.innerHTML = '#{COPY_ICON_SVG}';
          }, 2000);
          event.preventDefault();
        });
      </script>
    HTML
  end

  def self.html(content : String) : String
    options = Cmark::Option.flags(ValidateUTF8, Smart, Unsafe)
    html = Cmark.gfm_to_html(content, options)
    HtmlAutolink.new(html).call
  end
end
