class Guides::Testing::Introduction < GuideAction
  guide_route "/testing/introduction"

  def self.title
    "Intro to Testing"
  end

  def markdown : String
    <<-MD
    ## Getting Started

    Lucky uses the built-in Crystal method for testing specs. In Crystal, we refer to all of the tests
    collectively as a "spec suite". If you are unfamiliar with this term, it just refers to specifications.
    Read more on [testing in Crystal](https://crystal-lang.org/reference/guides/testing.html).

    All of your specs will go in the `spec/` directory located at the top level of your application.
    When you generate your Lucky project, there are a few files generated for you to help make testing
    easier. When you're ready to run your specs, you'll just run `crystal spec`.

    > The generated files will be different based on whether your app is API only, and whether you have
    > chosen to generate authentication files.

    ### spec_helper.cr

    The `spec/spec_helper.cr` file will require all of the necessary files and configuration your testing
    suite will need to run. Every time you add a new spec file for testing, you will need to require this file
    first.

    ## Flows

    If you need to test your HTML pages and/or the interactivity of your site (e.g. a user clicking a button to login),
    you will create your flow specs in the `spec/flows` directory.

    > If you generated a full Lucky app with authentication, you will have a few flow specs generated for you.

    ## Setup

    The `spec/setup/` directory is used to run necessary setup for your spec suite to work. Any additional setups
    needed before your spec suite runs should go in here. All files in `spec/setup` will be automatically required
    and ran in alphabetical order.

    There are a few setup steps generated with a new Lucky app.

    ### setup/clean_database.cr

    Before every spec, your database will automatically be truncated. This will wipe out any test records you've added in previous specs.

    ### setup/reset_emails.cr

    When sending email, [Carbon](https://github.com/luckyframework/carbon) will record delivery emails in memory so you can test
    whether an email has been sent. This step will clear the emails in memory before each step.

    ### setup/setup_database.cr

    This will create and migrate your test database for you. By default, Lucky apps will use the name of your app
    with the current environment as a suffix. (i.e. my_app_test or my_app_development).

    This can be configured in `config/database.cr`.

    > If you update migrations that have already been ran, you'll need to make sure your test database is updated as well.
    > To reset your test database, run `LUCKY_ENV=test lucky db.drop`, and then run `crystal spec`.

    ### setup/start_app_server.cr

    This file boots your Lucky app for your test suite to use so you can make requests directly to it. It will be
    stopped when your specs are all done running.

    ## Support

    Files in `spec/support/` contain code to make testing easier. This includes mock objects, objects for creating test
    data (e.g. [Factories](#{Guides::Testing::CreatingTestData.path})), and your Flow objects which are used in your flow specs,
    and whatever else you may need.

    ### support/api_client.cr

    The HTTP client you'll use to make requests to your API actions. See [#{Guides::Testing::TestingActions.title}](#{Guides::Testing::TestingActions.path})

    ### support/flows/

    The LuckyFlow objects used for testing your frontend. See [#{Guides::Testing::HtmlAndInteractivity.title}](#{Guides::Testing::HtmlAndInteractivity.path})

    ### support/factories/

    The Factories used for generating test data in your database. These are based off your models. See [#{Guides::Testing::CreatingTestData.title}](#{Guides::Testing::CreatingTestData.path})

    MD
  end
end
