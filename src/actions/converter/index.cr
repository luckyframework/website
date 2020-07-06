class ConvertHtmlToLucky::Index < BrowserAction
  get "/convert-html-to-lucky" do
    html IndexPage,
      title: "Convert HTML to Lucky",
      input: "",
      output: ""
  end
end
