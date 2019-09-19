class GuideCategory
  getter title, guides

  def initialize(@title : String, @guides : Array(GuideAction.class))
  end

  def active?(guide_action : GuideAction.class)
    guides.includes?(guide_action)
  end
end

class Guides::Sidebar < BaseComponent
  needs current_guide : GuideAction.class

  @categories : Array(GuideCategory)

  private getter categories = [
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

  def render
    div class: "text-black md:absolute pin-t pin-l bg-white md:rounded-lg shadow md:shadow-lg w-full md:w-sidebar md:mt-5 md:ml-2 pb-3 md:mb-10" do
      ul class: "list-reset" do
        li "Lucky v#{LuckyCliVersion.current_version}", class: "text-sm text-grey-dark tracking-wide border-b border-grey-light py-3 mt-3 px-8 md:ml-8 md:pl-0 mb-4"
        categories.each do |category|
          li do
            if category.active?(@current_guide)
              div class: "block pb-3 bg-grey-lighter border-t border-b border-grey shadow-inner" do
                span category.title, class: "pl-8 py-3 mb-2 block bold text-sm tracking-wide"
                category.guides.each do |guide|
                  if guide == @current_guide
                    link guide.title, guide, class: "block text-sm text-grey-darker no-underline pl-12 py-3 hover:underline #{active_class}"
                  else
                    link guide.title, guide, class: "block text-sm text-grey-darker no-underline pl-12 py-3 hover:underline hover:text-blue-dark"
                  end
                end
              end
            else
              link category.title, category.guides.first, class: "block text-sm tracking-wide text-grey-darker no-underline pl-8 py-3 hover:underline hover:text-blue-dark"
            end
          end
        end
      end
    end
  end

  def active_class
    "text-white bg-teal text-shadow hover:no-underline hover:text-white"
  end
end
