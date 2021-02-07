class Blog::Index < BrowserAction
  get "/blog" do
    html IndexPage, title: "Blog", posts: PostQuery.new.all
  end
end
