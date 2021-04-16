class GuidesList
  def self.categories : Array(GuideCategory)
    [
      GuideCategory.new("Getting Started", [
        Guides::GettingStarted::WhyLucky,
        Guides::GettingStarted::Installing,
        Guides::GettingStarted::StartingProject,
        Guides::GettingStarted::Concepts,
        Guides::GettingStarted::Configuration,
        Guides::GettingStarted::Logging,
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
      GuideCategory.new("Frontend and HTML", [
        Guides::Frontend::RenderingHtml,
        Guides::Frontend::HtmlForms,
        Guides::Frontend::AssetHandling,
        Guides::Frontend::Internationalization,
      ] of GuideAction.class),
      GuideCategory.new("Database", [
        Guides::Database::IntroToAvramAndORMs,
        Guides::Database::DatabaseSetup,
        Guides::Database::Migrations,
        Guides::Database::Models,
        Guides::Database::Querying,
        Guides::Database::ValidatingSaving,
        Guides::Database::DeletingRecords,
        Guides::Database::Pagination,
        Guides::Database::RawSql,
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
      GuideCategory.new("Handling Files", [
        Guides::HandlingFiles::FileUploads,
      ] of GuideAction.class),
      GuideCategory.new("Emails", [
        Guides::Emails::SendingEmailsWithCarbon,
      ] of GuideAction.class),
      GuideCategory.new("Deploying", [
        Guides::Deploying::Heroku,
        Guides::Deploying::Ubuntu,
        Guides::Deploying::Dokku,
      ] of GuideAction.class),
      GuideCategory.new("Testing", [
        Guides::Testing::Introduction,
        Guides::Testing::HtmlAndInteractivity,
        Guides::Testing::CreatingTestData,
        Guides::Testing::TestingActions,
        Guides::Testing::DebuggingTests,
        Guides::Testing::ContinuousIntegration,
      ] of GuideAction.class),
    ]
  end

  def self.next_guide(current_guide : GuideAction.class) : GuideAction.class | Nil
    index_of_current_guide = guides.index(current_guide)
    if index_of_current_guide
      guides[index_of_current_guide + 1]?
    end
  end

  def self.guides : Array(GuideAction.class)
    categories.flat_map &.guides
  end
end
