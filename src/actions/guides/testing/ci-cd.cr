class Guides::Testing::Introduction < GuideAction
    guide_route "/testing/ci-cd"
  
    def self.title
      "Setting up Continuous Integration"
    end
  
    def markdown : String
        <<-MD
        ## Setting up Continuous Integration
    
        Continuous integration (CI) is a system that automatically
        runs your tests every time you check in new code. That way,
        you can pinpoint the exact change you made that broke the
        build.

        There are lots of platforms that you can set up to 
        automatically run tests for you. Below is a list of systems 
        that are free and popular for open source projects:

        - [Travis CI](https://travis-ci.org/) - The `lucky` CLI 
            already generates a config file to set up Travis to run 
            your tests for you
        - [Circle CI](https://circleci.com/)
        - [GitHub actions](https://github.com/features/actions)

        
        There are pros and cons to each system and your choice depends
        on a variety of factors. We won't be describing how to choose
        here, we'll be explaining how to set each of these up if you
        choose to.

        ## Travis CI

        Lucky already generates a config file for 
        [Travis CI](https://travis-ci.org/), so if you choose to use
        that platform, congratulatioins! You're done.

        ## Circle CI

        If you choose to use Circle CI, please refer to the
        [Crystal Docs](https://crystal-lang.org/reference/guides/ci/circleci.html)
        on the subject. Since Lucky tests are just Crystal specs,
        this guide should be everything you need.

        ## GitHub Actions

        If you choose to use GitHub Actions, you can install the
        [Crystal Ameba Action](https://github.com/crystal-ameba/github-action).
        This will both run [Ameba](https://crystal-ameba.github.io/)
        to statically analyze your code, and then execute `crystal spec`
        to run your tests.

        Install the action by going to [this page](https://github.com/marketplace/actions/crystal-ameba-linter?version=v0.2.3)
        and clicking on the green button in the top right corner
        of the page.
        MD
  end
  end
  