class Learn::AwesomeLucky::Index < BrowserAction
  get "/awesome" do
    html Learn::AwesomeLucky::IndexPage, title: "Awesome Lucky"
  end
end
