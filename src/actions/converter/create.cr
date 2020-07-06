class ConvertHtmlToLucky::Create < BrowserAction
  param input : String = ""

  post "/convert-html-to-lucky" do
    output = HTML2Lucky::Converter.new(input).convert

    html IndexPage,
      title: "Convert HTML to Lucky",
      input: input,
      output: output
  end
end
