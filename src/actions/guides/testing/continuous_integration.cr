class Guides::Testing::ContinuousIntegration < GuideAction
  guide_route "/testing/continuous-integration"

  def self.title
    "Continuous Integration"
  end

  def markdown : String
    <<-MD
    ## Introduction

    Continuous Integration, or "CI", is system used to integrate your code by verifying the code with automated builds and tests. Then once verified, you
    can have your CI perform other actions like deploying to production, for example.

    Lucky apps are generated with a default CI using [Github Actions](https://github.com/features/actions). The CI setup will check that all of your
    code is formatted using the Crystal formatter `crystal tool format`, then it will run your specs. To activate this, all you need to do is push your
    code to Github! Once your code is pushed up to Github, Github will run the these two steps.

    To update the CI workflow, you'll make changes to `.github/workflows/ci.yml` in your application's directory. Refer to the Github Actions documentation for
    specifics.

    > Alternatively, Lucky apps also contain a `.travis.yml` file for configuring [Travis CI](https://travis-ci.org/).

    If you need any additional examples on using a CI with your Lucky application, all of the repos within the Lucky organization contain working Github Actions CI
    configurations.

    Here's a few links to get you started:

    - [LuckyCli](https://github.com/luckyframework/lucky_cli/blob/main/.github/workflows/ci.yml)
    - [Lucky](https://github.com/luckyframework/lucky/blob/main/.github/workflows/ci.yml)
    - [Avram](https://github.com/luckyframework/avram/blob/main/.github/workflows/ci.yml)
    - [Carbon](https://github.com/luckyframework/carbon/blob/main/.github/workflows/ci.yml)
    MD
  end
end
