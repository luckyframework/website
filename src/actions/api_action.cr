abstract class ApiAction < Lucky::Action
  # Include modules and add methods that are for all API requests
  disable_cookies
  accepted_formats [:json]
end
