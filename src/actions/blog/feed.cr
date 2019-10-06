class Blog::Feed < BrowserAction
  get "/blog/feed.xml" do
    posts = PostQuery.new.all[0...10]
    xml render_feed(posts)
  end

  private def render_feed(posts)
    items = posts.map do |post|
      url = Blog::Show.with(post.slug).url
      RSS::Item.new(
        guid: RSS::Guid.new(value: url, is_permalink: true),
        title: post.title,
        link: url,
        description: post.html_content,
        pub_date: post.published_at,
      )
    end
    last_build_date = posts.map(&.published_at).max

    feed = RSS::Channel.new(
      title: "Lucky Blog",
      description: "Lucky is a web framework written in Crystal",
      link: Blog::Index.url,
      feed_url: Blog::Feed.url,
      items: items,
      last_build_date: last_build_date,
    )

    feed.to_xml
  end
end
