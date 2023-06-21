class Team::Index < BrowserAction
  get "/team" do
    html Team::IndexPage, title: "The Lucky team"
  end
end
