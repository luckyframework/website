class HTML2Lucky::TagFactory
  getter depth, tag

  def initialize(@tag : Lexbor::Node, @depth : Int32)
  end

  def build : Tag
    tag_class.new(tag, depth)
  end

  private def tag_class : Tag.class
    if tag.is_text?
      TextTag
    elsif tag.is_comment?
      CommentTag
    elsif single_line_tag?(tag)
      SingleLineTag
    else
      MultiLineTag
    end
  end

  def single_line_tag?(tag)
    return false if tag.children.to_a.size != 1
    child_tag = tag.children.to_a.first
    return false unless child_tag.is_text?
    return true if child_tag.tag_text =~ /\A\s*\Z/
    return false if child_tag.tag_text =~ /\n/
    true
  end
end
