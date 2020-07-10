require "./tags/tag"
require "./tags/*"

class HTML2Lucky::Converter
  getter output = IO::Memory.new

  def initialize(@input : String)
  end

  def convert : String
    html = Lexbor::Parser.new("")
    body = html.body!
    body.inner_html = @input
    body.children.each do |child_tag|
      convert_tag(child_tag)
    end
    output.to_s
  end

  def convert_tag(tag)
    TagFactory.new(tag, depth: 0).build.print_io(output)
  end
end
