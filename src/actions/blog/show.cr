class Blog::Show < BrowserAction
  get "/blog/:post_slug" do
    post = PostQuery.new.find?(post_slug) || raise Lucky::RouteNotFoundError.new(context)
    html ShowPage, title: post.title, post: post
  end
end
