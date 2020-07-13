class HtmlConversions::New < BrowserAction
  get "/html" do
    html NewPage,
      title: "Convert HTML to Lucky",
      input: "",
      output: ""
  end
end
