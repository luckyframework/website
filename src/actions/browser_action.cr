abstract class BrowserAction < Lucky::Action
  include Lucky::ProtectFromForgery
  accepted_formats [:html, :json], default: :html
end
