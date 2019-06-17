# This action redirects the old guides index
class Guides::IndexRedirect < BrowserAction
  get "/guides" do
    redirect to: Guides::GettingStarted::Installing, status: HTTP::Status::MOVED_PERMANENTLY
  end
end
