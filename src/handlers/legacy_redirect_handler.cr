class LegacyRedirectHandler
  include HTTP::Handler
  REDIRECTS = {
    "/guides"                                     => Guides::GettingStarted::Installing,
    "/guides/overview"                            => Guides::GettingStarted::Concepts,
    "/guides/installing"                          => Guides::GettingStarted::Installing,
    "/guides/configuration"                       => Guides::GettingStarted::Configuration,
    "/guides/database-migrations"                 => Guides::Database::Migrations,
    "/guides/actions-and-routing"                 => Guides::HttpAndRouting::RoutingAndParams,
    "/guides/rendering-html"                      => Guides::Frontend::RenderingHtml,
    "/guides/querying-the-database"               => Guides::Database::QueryingDeleting,
    "/guides/custom-queries"                      => Guides::Database::RawSql,
    "/guides/saving-with-forms"                   => Guides::Database::ValidatingSaving,
    "/guides/asset-handling"                      => Guides::Frontend::AssetHandling,
    "/guides/tasks"                               => Guides::CommandLineTasks::BuiltIn,
    "/guides/logging-and-error-handling"          => Guides::GettingStarted::Logging,
    "/guides/writing-json-apis"                   => Guides::JsonAndApis::RenderingJson,
    "/guides/json-and-apis/handling-errors"       => Guides::HttpAndRouting::ErrorHandling,
    "/guides/generating-test-data"                => Guides::Database::Testing,
    "/guides/browser-tests"                       => Guides::Frontend::Testing,
    "/guides/sending-emails"                      => Guides::Emails::SendingEmailsWithCarbon,
    "/guides/authentication"                      => Guides::Authentication::Intro,
    "/guides/deploying-heroku"                    => Guides::Deploying::Heroku,
    "/guides/database/validating-saving-deleting" => Guides::Database::ValidatingSaving,
    "/guides/database/querying"                   => Guides::Database::QueryingDeleting,
  }

  def call(context)
    response = context.response
    path = context.request.path.rchop('/')
    if new_route = REDIRECTS[path]?
      Lucky.logger.info(handled_by: LegacyRedirectHandler.name)
      response.status_code = HTTP::Status::MOVED_PERMANENTLY.value
      response.headers["Location"] = new_route.url
      return
    end
    call_next(context)
  end
end
