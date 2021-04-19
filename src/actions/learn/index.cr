class Learn::Index < BrowserAction
  get "/learn" do
    html Learn::IndexPage, title: "Learn the Lucky Framework"
  end
end
