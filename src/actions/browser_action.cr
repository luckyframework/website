abstract class BrowserAction < Lucky::Action
  include Lucky::ProtectFromForgery
  # TODO: once we enable this, we will need to legacy redirect many guides
  # include Lucky::EnforceUnderscoredRoute
  include Lucky::SecureHeaders::DisableFLoC
  accepted_formats [:html, :json], default: :html
end
