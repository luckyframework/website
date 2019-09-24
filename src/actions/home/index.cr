class Home::Index < BrowserAction
  get "/" do
    html Home::IndexPage
  end
end
