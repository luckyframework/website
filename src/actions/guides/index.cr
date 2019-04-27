class Guides::Index < BrowserAction
  route do
    redirect Show.with("overview")
  end
end
