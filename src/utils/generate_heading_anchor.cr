class GenerateHeadingAnchor
  def initialize(@heading_text : String)
  end

  def call : String
    @heading_text.gsub(" ", "-").downcase
  end
end
