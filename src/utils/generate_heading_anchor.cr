class GenerateHeadingAnchor
  def initialize(heading_text : String)
    @heading_text = HTML.unescape(heading_text)
  end

  def call : String
    @heading_text.gsub(" ", "-").downcase
  end
end
