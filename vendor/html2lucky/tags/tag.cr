abstract class HTML2Lucky::Tag
  QUOTE      = '"'
  NAMED_TAGS = Lucky::BaseTags::TAGS +
               Lucky::BaseTags::EMPTY_TAGS +
               Lucky::BaseTags::RENAMED_TAGS.values.to_a

  getter depth, tag

  def initialize(@tag : Lexbor::Node, @depth : Int32)
  end

  abstract def print_io(io : IO) : IO

  def padding
    " " * (depth * 2)
  end

  def method_name
    if renamed_tag_method = Lucky::BaseTags::RENAMED_TAGS.to_h.invert[tag_name]?
      renamed_tag_method
    elsif custom_tag?
      "tag #{wrap_quotes(tag_name)}"
    else
      tag_name
    end
  end

  private def custom_tag?
    !NAMED_TAGS.map(&.to_s).includes?(tag_name)
  end

  def method_joiner
    if custom_tag?
      ", "
    else
      " "
    end
  end

  private def tag_name
    tag.tag_name
  end

  def attr_parameters
    convert_attributes_to_parameters.sort_by do |string|
      string.gsub(/\"/, "")
    end
  end

  def attr_text
    attr_parameters.join(", ")
  end

  def convert_attributes_to_parameters
    tag.attributes.map do |key, value|
      if lucky_can_handle_as_symbol?(key)
        "#{key.tr("-", "_")}: \"#{value}\""
      else
        "#{wrap_quotes(key)}: \"#{value}\""
      end
    end
  end

  private def lucky_can_handle_as_symbol?(key)
    contains_only_alphanumeric_or_dashes?(key)
  end

  private def contains_only_alphanumeric_or_dashes?(key) : Bool
    (key =~ /[^\da-zA-Z\-]/).nil?
  end

  def squish(string : String)
    two_or_more_whitespace = /\s{2,}/
    string.gsub(two_or_more_whitespace, " ")
      .gsub(/\A\s+/, " ")
      .gsub(/\s+\Z/, " ")
  end

  private def wrap_quotes(string : String) : String
    QUOTE + string + QUOTE
  end
end
