class Blog::Index < BrowserAction
  route do
    render IndexPage, title: "Blog", posts: PostQuery.new.all
  end
end
