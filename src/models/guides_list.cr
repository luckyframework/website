class GuidesList
  def self.categories : Array(GuideCategory)
    [
      GuideCategory.new("Getting Started", [
        Guides::GettingStarted::WhyLucky,
        Guides::GettingStarted::Installing,
        Guides::GettingStarted::StartingProject,
        Guides::GettingStarted::Concepts,
        Guides::GettingStarted::Configuration,
      ] of GuideAction.class),
      GuideCategory.new("HTTP and Routing", [
        Guides::HttpAndRouting::RoutingAndParams,
        Guides::HttpAndRouting::RequestAndResponse,
        Guides::HttpAndRouting::BeforeAfterActions,
        Guides::HttpAndRouting::LinkGeneration,
        Guides::HttpAndRouting::SessionsAndCookies,
        Guides::HttpAndRouting::Flash,
        Guides::HttpAndRouting::ErrorHandling,
        Guides::HttpAndRouting::HTTPHandlers,
        Guides::HttpAndRouting::SecurityHeaders,
      ] of GuideAction.class),
      GuideCategory.new("Frontend", [
        Guides::Frontend::RenderingHtml,
        Guides::Frontend::AssetHandling,
        Guides::Frontend::Testing,
      ] of GuideAction.class),
      GuideCategory.new("Database", [
        Guides::Database::IntroToAvramAndORMs,
        Guides::Database::DatabaseSetup,
        Guides::Database::Migrations,
        Guides::Database::Models,
        Guides::Database::QueryingDeleting,
        Guides::Database::ValidatingSaving,
        Guides::Database::RawSql,
        Guides::Database::Testing,
      ] of GuideAction.class),
      GuideCategory.new("JSON and APIs", [
        Guides::JsonAndApis::RenderingJson,
        Guides::JsonAndApis::ParsingJsonRequests,
        Guides::JsonAndApis::SavingToTheDatabase,
        Guides::JsonAndApis::Cors,
      ] of GuideAction.class),
      GuideCategory.new("Authentication", [
        Guides::Authentication::Intro,
        Guides::Authentication::Browser,
        Guides::Authentication::Api,
      ] of GuideAction.class),
      GuideCategory.new("Command Line Tasks", [
        Guides::CommandLineTasks::BuiltIn,
        Guides::CommandLineTasks::CustomTasks,
      ] of GuideAction.class),
      GuideCategory.new("Emails", [
        Guides::Emails::SendingEmailsWithCarbon,
      ] of GuideAction.class),
      GuideCategory.new("Deploying", [
        Guides::Deploying::Heroku,
        Guides::Deploying::Ubuntu,
      ] of GuideAction.class),
    ]
  end
end
