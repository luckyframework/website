class LegacyRedirectHandler
  include HTTP::Handler
  REDIRECTS = {
    "/convert-html-to-lucky"                      => HtmlConversions::New.url,
    "/guides"                                     => Guides::GettingStarted::Installing.url,
    "/guides/overview"                            => Guides::GettingStarted::Concepts.url,
    "/guides/installing"                          => Guides::GettingStarted::Installing.url,
    "/guides/configuration"                       => Guides::GettingStarted::Configuration.url,
    "/guides/database-migrations"                 => Guides::Database::Migrations.url,
    "/guides/actions-and-routing"                 => Guides::HttpAndRouting::RoutingAndParams.url,
    "/guides/rendering-html"                      => Guides::Frontend::RenderingHtml.url,
    "/guides/querying-the-database"               => Guides::Database::Querying.url,
    "/guides/custom-queries"                      => Guides::Database::RawSql.url,
    "/guides/saving-with-forms"                   => Guides::Database::ValidatingSaving.url,
    "/guides/asset-handling"                      => Guides::Frontend::AssetHandling.url,
    "/guides/tasks"                               => Guides::CommandLineTasks::BuiltIn.url,
    "/guides/logging-and-error-handling"          => Guides::GettingStarted::Logging.url,
    "/guides/writing-json-apis"                   => Guides::JsonAndApis::RenderingJson.url,
    "/guides/json-and-apis/handling-errors"       => Guides::HttpAndRouting::ErrorHandling.url,
    "/guides/generating-test-data"                => Guides::Testing::CreatingTestData.url,
    "/guides/database/testing"                    => Guides::Testing::CreatingTestData.url,
    "/guides/browser-tests"                       => Guides::Testing::HtmlAndInteractivity.url,
    "/guides/frontend/testing"                    => Guides::Testing::HtmlAndInteractivity.url,
    "/guides/sending-emails"                      => Guides::Emails::SendingEmailsWithCarbon.url,
    "/guides/authentication"                      => Guides::Authentication::Intro.url,
    "/guides/deploying-heroku"                    => Guides::Deploying::Heroku.url,
    "/guides/database/validating-saving-deleting" => Guides::Database::ValidatingSaving.url,
    "/guides/database/querying"                   => Guides::Database::Querying.url,
    "/guides/database/querying-deleting"          => Guides::Database::Querying.url,
  }

  def call(context)
    response = context.response
    path = context.request.path.rchop('/')
    if new_url = REDIRECTS[path]?
      Lucky::Log.dexter.info { {handled_by: LegacyRedirectHandler.name} }
      response.status_code = HTTP::Status::MOVED_PERMANENTLY.value
      response.headers["Location"] = new_url
      return
    end
    call_next(context)
  end
end
