class Shared::LayoutHead < BaseComponent
  needs seo : SEO
  needs context : HTTP::Server::Context

  def render
    head do
      utf8_charset
      title "Lucky - #{@seo.page_title}"
      css_link asset("css/app.css"), data_turbolinks_track: "reload"
      js_link asset("js/app.js"), defer: "defer", data_turbolinks_track: "reload"
      csrf_meta_tags
      meta name: "description", content: @seo.page_description

      responsive_meta_tag
      meta name: "mobile-web-app-capable", content: "yes"

      script src: "https://buttons.github.io/buttons.js", attrs: [:async, :defer]
      css_link "https://cdn.jsdelivr.net/npm/docsearch.js@2/dist/cdn/docsearch.min.css"
      script type: "text/javascript", src: "https://cdn.jsdelivr.net/npm/docsearch.js@2/dist/cdn/docsearch.min.js"
    end
  end
end
