class Blog::Index < BrowserAction
  route do
    html IndexPage, title: "Blog", posts: PostQuery.new.all
  end
end
