abstract class GuideAction < BrowserAction
  include Lucky::ProtectFromForgery

  expose markdown
  expose title
  expose guide_file_path

  abstract def markdown : String

  def title
    self.class.title
  end

  macro guide_route(path)
    get {{ "/guides" + path }} do
      render Guides::ShowPage, guide_action: self.class
    end
  end

  private def render_guide
    render Guides::ShowPage
  end

  private def permalink(anchor : String) : String
    %(<div id="#{anchor}"></div>\n)
  end

  macro inherited
    private def guide_file_path
      __FILE__
    end
  end
end
