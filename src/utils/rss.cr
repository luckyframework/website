require "xml"

module RSS
  class Channel
    def initialize(@posts : Array(BasePost))
    end

    def to_xml
      XML.build(encoding: "UTF-8") do |xml|
        xml.element("rss", "xmlns:atom": "http://www.w3.org/2005/Atom", version: "2.0") do
          xml.element("channel") do
            xml.element("title") { xml.text "Lucky Blog" }
            xml.element("description") { xml.text "Lucky is a web framework written in Crystal" }
            xml.element("link") { xml.text Blog::Index.url }
            xml.element("atom", "link", nil, rel: "self", href: Blog::Feed.url)
            xml.element("lastBuildDate") { xml.text last_build_date.to_rfc2822 }

            items.each &.to_xml(xml)
          end
        end
      end
    end

    private def items
      @posts.map do |post|
        url = post_url(post)

        RSS::Item.new(
          guid: RSS::Guid.new(value: url, is_permalink: true),
          title: post.title,
          link: url,
          description: post.html_content,
          pub_date: post.published_at,
        )
      end
    end

    private def last_build_date
      @posts.max_of(&.published_at)
    end

    private def post_url(post)
      Blog::Show.with(post.slug).url
    end
  end

  class Item
    def initialize(@guid : Guid, @title : String, @link : String, @description : String, @pub_date : Time)
    end

    def to_xml(xml : XML::Builder)
      xml.element("item") do
        @guid.to_xml(xml)
        xml.element("pubDate") { xml.text @pub_date.to_rfc2822 }
        xml.element("title") { xml.text @title }
        xml.element("link") { xml.text @link }
        xml.element("description") { xml.cdata @description }
      end
    end
  end

  struct Guid
    def initialize(@value : String, @is_permalink : Bool)
    end

    def to_xml(xml : XML::Builder)
      xml.element("guid", "isPermaLink": @is_permalink) { xml.text @value }
    end
  end
end
