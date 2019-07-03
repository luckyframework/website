class HTML2Lucky::TextTag < HTML2Lucky::Tag
  ONLY_WHITE_SPACE = /\A\s+\Z/

  def print_io(io)
    if has_content?
      io << output_for_text_tag
      io << "\n"
    end
  end

  private def has_content? : Bool
    !(raw_text =~ ONLY_WHITE_SPACE)
  end

  private def raw_text
    squish(tag.tag_text)
  end

  private def output_for_text_tag : String
    line = raw_text.tr("\n", " ")
    line = wrap_quotes(line)
    padding + "text #{line}"
  end
end
