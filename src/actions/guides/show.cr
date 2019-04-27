require "markdown"

class Guides::Show < BrowserAction
  expose guide_path

  get "/guides/:guide_filename" do
    render Guides::ShowPage, markdown: markdown
  end

  def markdown
    File.read(guide_path)
  rescue e : Errno
    raise Lucky::RouteNotFoundError.new(@context)
  end

  def guide_path
    self.class.guide_path(guide_filename)
  end

  def self.guide_path(guide_filename)
    "./src/guides/#{guide_filename}.md"
  end

  def self.route(guide_filename)
    guide_path = guide_path(guide_filename)
    if File.exists?(guide_path)
      previous_def(guide_filename)
    else
      raise "Couldn't find a guide at: #{guide_path}"
    end
  end
end
