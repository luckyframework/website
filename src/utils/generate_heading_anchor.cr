class GenerateHeadingAnchor
  def initialize(@heading_text : String)
  end

  def call : String
    text = HTML.unescape(@heading_text)
      .gsub("&", "-")
      .gsub(/<[^>]*>/, "") # Remove HTML tags
    Cadmium::Transliterator.parameterize(text)
  end
end
