abstract class ApiAction < Lucky::Action
  # Include modules and add methods that are for all API requests
  disable_cookies
  accepted_formats [:json]

  # By default all actions are required to use underscores to separate words.
  # Add 'include Lucky::SkipRouteStyleCheck' to your actions if you wish to ignore this check for specific routes.
  include Lucky::EnforceUnderscoredRoute
end
