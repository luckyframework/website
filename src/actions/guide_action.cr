abstract class GuideAction < BrowserAction
  include Lucky::ProtectFromForgery

  expose markdown
  expose title

  abstract def markdown : String
  abstract def title : String

  macro guide_route(path)
    get {{ "/guides" + path }} do
      render Guides::ShowPage, guide_action: self.class
    end
  end

  private def render_guide
    render Guides::ShowPage
  end
end
