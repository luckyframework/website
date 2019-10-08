class Blog::Feed < BrowserAction
  get "/blog/feed.xml" do
    posts = PostQuery.new.all.first(10)
    xml RSS::Channel.new(posts).to_xml
  end
end
