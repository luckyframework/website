abstract class BasePost
  macro inherited
    PostQuery::POSTS << self.new
  end

  abstract def title : String
  abstract def content : String
  abstract def summary : String
  abstract def slug : String
  abstract def published_at : Time

  macro title(value)
    def title
      {{ value }}
    end
  end

  macro slug(value)
    def slug
      {{ value }}
    end
  end

  def unpublished? : Bool
    published_at > Time.utc
  end

  def html_content : String
    CustomMarkdownRenderer.render_to_html(content)
  end
end
