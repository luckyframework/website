abstract class BasePost
  macro inherited
    PostQuery::POSTS << self.new
  end

  abstract def title : String
  abstract def content : String
  abstract def summary : String
  abstract def slug : String

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

  def published_at : Time?
  end

  def html_content : String
    CustomMarkdownRenderer.render_to_html(content)
  end
end
