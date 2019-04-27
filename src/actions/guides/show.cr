require "markdown"

class Guides::Show < BrowserAction
  get "/guides/:guide_filename" do
    render Guides::ShowPage, markdown: markdown
  end

  def markdown
    File.read(guide_path)
  rescue e : Errno
    raise Lucky::RouteNotFoundError.new(@context)
  end

  def guide_path
    "./src/guides/#{guide_filename}.md"
  end
end
