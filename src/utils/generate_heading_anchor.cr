class GenerateHeadingAnchor
  def initialize(heading_text : String)
    @heading_text = HTML.unescape(heading_text)
  end

  def call : String
    Cadmium::Transliterator.parameterize(@heading_text.gsub("&", "-"))
  end
end
