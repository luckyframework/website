require "./spec_helper"
require "../vendor/html2lucky/converter"

describe HTML2Lucky::Converter do
  it "converts basic html" do
    input = "<div><p>Before Link<a>Link</a> After Link</p></div>"
    expected_output = <<-CODE
    div do
      para do
        text "Before Link"
        a "Link"
        text " After Link"
      end
    end
    CODE

    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "uses block syntax when inner text has new lines" do
    input = "<div class='some-class'>First Line\nSecond Line</div>"
    expected_output = <<-CODE
    div class: "some-class" do
      text "First Line Second Line"
    end
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "handles empty tags properly" do
    input = "<div></div>"
    expected_output = <<-CODE
    div
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "includes simple attributes" do
    input = "<div class='some-class'>Hello</div>"
    expected_output = <<-CODE
    div "Hello", class: "some-class"
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "includes multiple attributes" do
    input = "<div class='some-class-1 some-class-2' id='abc'>Hello</div>"
    expected_output = <<-CODE
    div "Hello", class: "some-class-1 some-class-2", id: "abc"
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "includes attributes that need quoting" do
    input = "<div class='some-class-1' data-id='123'>Hello</div>"
    expected_output = <<-CODE
    div "Hello", class: "some-class-1", data_id: "123"
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "converts multiple empty spaces into just one space" do
    input = "<div>  \n\n  </div>"
    expected_output = <<-CODE
    div " "
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "converts a tag with just new lines into a space" do
    input = "<div>\n</div>"
    expected_output = <<-CODE
    div " "
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "converts just a tag with attributes and new lines into a tag with attributes and a space" do
    input = "<div class='some-class'>\n</div>"
    expected_output = <<-CODE
    div " ", class: "some-class"
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "converts leading new lines into a space" do
    input = "<div>\nHello</div>"
    expected_output = <<-CODE
    div do
      text " Hello"
    end
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "removes leading space" do
    input = "<div> <a>Link</a></div>"
    expected_output = <<-CODE
    div do
      a "Link"
    end
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "removes trailing space" do
    input = "<div><a>Link</a> </div>"
    expected_output = <<-CODE
    div do
      a "Link"
    end
    CODE
    output = HTML2Lucky::Converter.new(input).convert
    output.should eq_html(expected_output.strip)
  end

  it "converts trailing new lines into a space" do
    input = "<div>Hello\n</div>"

    output = HTML2Lucky::Converter.new(input).convert

    output.should eq_html <<-CODE
    div do
      text "Hello "
    end
    CODE
  end

  it "converts new lines inside of text into multiple text calls" do
    input = "<div>First\nSecond\nThird</div>"

    output = HTML2Lucky::Converter.new(input).convert

    output.should eq_html <<-CODE
    div do
      text "First Second Third"
    end
    CODE
  end

  it "doesn't print empty text in between tags" do
    input = "<div></div>\n<div></div>"

    output = HTML2Lucky::Converter.new(input).convert

    output.should eq_html <<-CODE
    div
    div
    CODE
  end

  it "prints attributes for tags without children" do
    input = "<div class='foo'></div>"

    output = HTML2Lucky::Converter.new(input).convert

    output.should eq_html <<-CODE
    div class: "foo"
    CODE
  end

  it "prints quotes around weird attributes names" do
    input = "<div @click.prevent='foo'></div>"

    output = HTML2Lucky::Converter.new(input).convert

    output.should eq_html <<-CODE
    div "@click.prevent": "foo"
    CODE
  end

  it "prints quotes when using underscores" do
    input = "<div underscore_attribute='foo'></div>"

    output = HTML2Lucky::Converter.new(input).convert

    output.should eq_html <<-CODE
    div "underscore_attribute": "foo"
    CODE
  end

  it "works with custom tags" do
    input = <<-HTML
    <foo></foo>
    <foo-bar></foo-bar>
    <foo-bar class="foo"></foo-bar>
    <foo-bar class="foo">text</foo-bar>
    <div>
      <foo-bar class="foo">
        text
      </foo-bar>
    </div>
    HTML

    output = HTML2Lucky::Converter.new(input).convert

    output.should eq_html <<-CODE
    tag "foo"
    tag "foo-bar"
    tag "foo-bar", class: "foo"
    tag "foo-bar", "text", class: "foo"
    div do
      tag "foo-bar", class: "foo" do
        text " text "
      end
    end
    CODE
  end

  it "doesn't crash on invalid input" do
    input = "<div <p>></p>"
    HTML2Lucky::Converter.new(input).convert
  end

  it "treats renamed tags as non-custom tags" do
    input = "<p>Hello</p>"
    output = HTML2Lucky::Converter.new(input).convert

    output.should eq_html %q(para "Hello")
  end

  describe "converting comments" do
    it "does not render a comment" do
      input = "<!-- this comment -->"
      output = HTML2Lucky::Converter.new(input).convert

      output.should eq ""
    end

    it "strips comments from inside of tags" do
      input = "<div><!-- secret --><span>the man</span></div>"
      output = HTML2Lucky::Converter.new(input).convert

      output.should eq_html <<-CODE
      div do
        span "the man"
      end
      CODE
    end

    it "handles multiline comments" do
      input = <<-HTML
      <div>one</div>
      <!--
      comment here
      and more stuff here
      -->
      <div>two</div>
      HTML
      output = HTML2Lucky::Converter.new(input).convert

      output.should eq_html <<-CODE
      div "one"
      div "two"
      CODE
    end
  end
end

private def eq_html(html)
  eq html + "\n"
end
