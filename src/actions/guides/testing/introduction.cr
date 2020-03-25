class Guides::Testing::Introduction < GuideAction
  guide_route "/testing/introduction"

  def self.title
    "Testing Introduction"
  end

  def markdown : String
    <<-MD
    ## Getting Started

    All of your tests will go in the `spec/` directory located at the top level of your application.
    When you generate your Lucky project, there are a few files generated for you to help make testing
    easier.

    ### spec_helper.cr

    The `spec/spec_helper.cr` file will require all of the necessary files, and configuration your testing
    suite will need to run. Every time you add a new spec file for testing, you will need to require this file
    first.

    ## Flows

    If you need to test your HTML views and/or the interactivity of your site (e.g. a user clicking a button to login),
    you will create your flow specs in this directory.

    ## Setup

    This directory is used to setup all of your testing. Any additional setups needed before your spec suite runs
    should go in here. They will be automatically required and ran in alphabetical order.

    ### setup/clean_database.cr

    ### setup/reset_emails.cr

    ### setup/setup_database.cr

    ### setup/start_app_server.cr

    ## Support

    Support files are files needed to make testing easier. This includes mock objects, model tests (a.k.a Boxes), and
    your Flow objects which are used in your flow specs.

    ### support/app_client.cr

    ### support/flows/

    ### support/boxes/

    MD
  end
end
