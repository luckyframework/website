class HtmlConversions::Create < BrowserAction
  param input : String = ""

  post "/html" do
    output = HTML2Lucky::Converter.new(input).convert

    html NewPage,
      title: "Convert HTML to Lucky",
      input: input,
      output: output
  end
end
