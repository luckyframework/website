# This action redirects the old guides to the new ones
class Guides::Redirect < BrowserAction
  REDIRECTS = {
    "overview"                   => Guides::GettingStarted::Concepts,
    "installing"                 => Guides::GettingStarted::Installing,
    "configuration"              => Guides::GettingStarted::Configuration,
    "database-migrations"        => Guides::Database::Migrations,
    "actions-and-routing"        => Guides::HttpAndRouting::RoutingAndParams,
    "rendering-html"             => Guides::Frontend::RenderingHtml,
    "querying-the-database"      => Guides::Database::QueryingDeleting,
    "custom-queries"             => Guides::Database::RawSql,
    "saving-with-forms"          => Guides::Database::ValidatingSaving,
    "asset-handling"             => Guides::Frontend::AssetHandling,
    "tasks"                      => Guides::CommandLineTasks::BuiltIn,
    "logging-and-error-handling" => Guides::Logging,
    "writing-json-apis"          => Guides::JsonAndApis::RenderingJson,
    "generating-test-data"       => Guides::Database::Testing,
    "browser-tests"              => Guides::Frontend::Testing,
    "sending-emails"             => Guides::Emails::SendingEmailsWithCarbon,
    "authentication"             => Guides::Authentication::Show,
    "deploying-heroku"           => Guides::Deploying::Heroku,
    "database/validating-saving-deleting" => Guides::Database::ValidatingSaving,
    "database/querying"          => Guides::Database::QueryingDeleting
  }

  fallback do
    guide_path = request.path.gsub("/guides/", "")
    if new_guide = REDIRECTS[guide_path]?
      redirect to: new_guide, status: HTTP::Status::MOVED_PERMANENTLY
    else
      raise Lucky::RouteNotFoundError.new(context)
    end
  end
end
