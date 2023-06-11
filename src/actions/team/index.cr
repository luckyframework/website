class Team::Index < BrowserAction
  get "/team" do
    html Team::IndexPage, title: "The Core Team of Lucky"
  end
end
