class CustomMarkdownRenderer < Markd::HTMLRenderer
  def heading(node : Markd::Node, entering : Bool)
    level = node.data["level"]
    tag_name = "h#{level}"
    if entering
      cr
      last_child = node.last_child?
      if last_child
        # This is the custom part
        anchor_name = GenerateHeadingAnchor.new(last_child.text).call
        tag(tag_name, {"id" => anchor_name})
        tag("a", {"href" => "##{anchor_name}", "class" => "md-anchor"})
        out("#")
        tag("/a")
      else
        tag(tag_name, attrs(node))
      end
    else
      tag("/#{tag_name}")
      last_child = node.last_child?
      cr
    end
  end

  def self.render_to_html(content)
    options = Markd::Options.new(smart: true)
    document = Markd::Parser.parse(content, options)
    new(options).render(document)
  end
end
