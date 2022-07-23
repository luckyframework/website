class Learn::Community::Index < BrowserAction
  get "/community" do
    html Learn::Community::IndexPage, title: "Lucky Community"
  end
end
