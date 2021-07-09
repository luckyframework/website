class Media::Index < BrowserAction
  get "/media" do
    html Media::IndexPage, title: "The Lucky Framework Brand"
  end
end
