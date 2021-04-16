abstract class GuideAction < BrowserAction
  expose markdown
  expose title
  expose guide_file_path

  abstract def markdown : String

  def title
    self.class.title
  end

  macro guide_route(path)
    get {{ "/guides" + path }} do
      html Guides::ShowPage, guide_action: self.class
    end
  end

  private def render_guide
    html Guides::ShowPage
  end

  private def permalink(anchor : String) : String
    %(<div id="#{anchor}"></div>\n)
  end

  macro inherited
    def self.guide_file_path
      __FILE__
    end

    private def guide_file_path
      __FILE__
    end
  end
end
