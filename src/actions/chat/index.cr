class Chat::Index < BrowserAction
  get "/chat" do
    redirect to: "https://discord.gg/HeqJUcb"
  end
end
