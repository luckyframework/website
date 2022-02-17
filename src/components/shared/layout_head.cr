class Shared::LayoutHead < BaseComponent
  needs seo : SEO

  def render
    head do
      utf8_charset
      title "Lucky - #{@seo.page_title}"
      css_link asset("css/app.css"), data_turbo_track: "reload"
      js_link asset("js/app.js"), defer: "defer", data_turbo_track: "reload"
      csrf_meta_tags
      meta name: "description", content: @seo.page_description
      rss_link

      responsive_meta_tag
      meta name: "mobile-web-app-capable", content: "yes"
      open_graph_tags

      script src: "https://buttons.github.io/buttons.js", attrs: [:async, :defer]
      tag("link", rel: "preconnect", href: "https://P30IY9NAHF-dsn.algolia.net", attrs: [:crossorigin])
    end
  end

  # These control how cards are displayed when pages are shared
  # on social media. http://ogp.me/
  private def open_graph_tags
    meta property: "og:title", content: @seo.page_title
    meta property: "og:url", content: Home::Index.url
    meta property: "og:type", content: "website"
    meta property: "og:description", content: @seo.page_description
    meta property: "og:locale", content: "en_US"
    meta property: "og:image", content: Lucky::RouteHelper.settings.base_uri + asset("images/lucky_og_screenshot.png")
  end

  private def rss_link
    tag "link", rel: "alternate", type: "application/rss+xml", href: Blog::Feed.url, title: "Lucky Blog"
  end
end
