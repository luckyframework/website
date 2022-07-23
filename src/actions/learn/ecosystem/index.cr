class Learn::Ecosystem::Index < BrowserAction
  get "/ecosystem" do
    html Learn::Ecosystem::IndexPage, title: "The Lucky Framework Ecosystem"
  end
end
