class HTML2Lucky::SingleLineTag < HTML2Lucky::Tag
  def print_io(io) : IO
    content = wrap_quotes(squish(tag.children.first.tag_text))
    io << padding
    io << method_name
    io << method_joiner
    io << [content, attr_text].reject(&.empty?).join(", ")
    io << "\n"
  end
end
