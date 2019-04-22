class Home::Index < BrowserAction
  get "/" do
    render Home::IndexPage
  end
end
