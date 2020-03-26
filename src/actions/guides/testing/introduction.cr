class Guides::Testing::Introduction < GuideAction
  guide_route "/testing/introduction"

  def self.title
    "Intro to Testing"
  end

  def markdown : String
    <<-MD
    ## Getting Started

    All of your tests will go in the `spec/` directory located at the top level of your application.
    When you generate your Lucky project, there are a few files generated for you to help make testing
    easier.

    > The generated files will be different based on whether your app is API only, and whether you have chosen to generate authentication files.

    ### spec_helper.cr

    The `spec/spec_helper.cr` file will require all of the necessary files and configuration your testing
    suite will need to run. Every time you add a new spec file for testing, you will need to require this file
    first. Read more on [testing in Crystal](https://crystal-lang.org/reference/guides/testing.html).

    ## Flows

    If you need to test your HTML pages and/or the interactivity of your site (e.g. a user clicking a button to login),
    you will create your flow specs in the `spec/flows` directory.

    > If you generated a full Lucky app with authentication, you will have a few flow specs generated for you.

    ## Setup

    This directory is used to setup all of your testing. Any additional setups needed before your spec suite runs
    should go in here. All files in `spec/setup` will be automatically required and ran in alphabetical order.

    ### setup/clean_database.cr

    Before every spec, your database will automatically be truncated wiping out any test records you've added.

    ### setup/reset_emails.cr

    Every test email sent is tracked as delivered. This will clear out "delivered" test email before each spec.

    ### setup/setup_database.cr

    This will create and migrate your test database for you. By default, Lucky apps will use the name of your app
    with the current environment as a suffix. (i.e. my_app_test or my_app_development).

    This is ran for you when you run `crystal spec`.

    ### setup/start_app_server.cr

    This file boots your Lucky app for your test suite to use so you can make requests directly to it. It will be
    stopped when your specs are all done running.

    ## Support

    Support files are files needed to make testing easier. This includes mock objects, model tests (a.k.a Boxes), and
    your Flow objects which are used in your flow specs, and whatever else you may need.

    ### support/app_client.cr

    The HTTP client you'll use to make requests to your actions. See [#{Guides::Testing::TestingActions.title}](#{Guides::Testing::TestingActions.path})

    ### support/flows/

    The Flows used for testing your frontend. See [#{Guides::Testing::HtmlAndInteractivity.title}](#{Guides::Testing::HtmlAndInteractivity.path})

    ### support/boxes/

    The Boxes used for generating test data in your database. These are based off your models. See [#{Guides::Testing::CreatingTestData.title}](#{Guides::Testing::CreatingTestData.path})

    MD
  end
end
