class WhyLucky::Redirect < BrowserAction
  get "/why-lucky" do
    redirect to: Guides::GettingStarted::WhyLucky
  end
end
