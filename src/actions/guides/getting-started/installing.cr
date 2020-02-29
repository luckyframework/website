class Guides::GettingStarted::Installing < GuideAction
  ANCHOR_INSTALL_REQUIRED_DEPENDENCIES = "perma-install-required-dependencies"
  guide_route "/getting-started/installing"

  def self.title
    "Installing Lucky"
  end

  def markdown : String
    <<-MD
    #{permalink(ANCHOR_INSTALL_REQUIRED_DEPENDENCIES)}
    ## Install Required Dependencies

    ### Crystal v0.33.0

    **We recommend using a version manager** to make sure the correct
    version of Crystal is used with Lucky.
    Try [crenv](https://github.com/pine/crenv) (recommended) or
    [asdf-crystal](https://github.com/marciogm/asdf-crystal) (great if you already use [asdf](https://github.com/asdf-vm/asdf))

    Alternatively you could [install Crystal without a version manager](https://crystal-lang.org/reference/installation/).

    ### Process manager

    Lucky uses a process manager to watch assets and start the server in development.

    Install one of these process managers: [Overmind (recommended)](https://github.com/DarthSim/overmind#installation),
    [Heroku CLI (great if you plan to use Heroku to deploy)](https://devcenter.heroku.com/articles/heroku-cli#download-and-install),
    [forego](https://github.com/ddollar/forego#installation),
    or [foreman](https://github.com/ddollar/foreman#installation).

    > By  default Lucky creates a `Procfile.dev` that  defines  what processes should be started when running `lucky dev`.
    > You can modify the `Procfile.dev` to start other processes like running
    > background jobs.

    ### Postgres database

    Lucky uses Postgres for its database. Install Postgres ([macOS](https://postgresapp.com)/[Others](https://wiki.postgresql.org/wiki/Detailed_installation_guides))

    ### Debian and Fedora dependencies

    * Debian (Ubuntu should be similar): run `apt-get install libc6-dev libevent-dev libpcre2-dev libpng-dev libssl1.0-dev libyaml-dev zlib1g-dev`
    * Fedora (28): run `dnf install glibc-devel libevent-devel pcre2-devel openssl-devel libyaml-devel zlib-devel libpng-devel`. libpng-devel is for Laravel Mix

    ### For building assets (skip if building APIs)

    * [Node](https://nodejs.org/en/download/). Requires at least v6
    * [Yarn](https://yarnpkg.com/lang/en/docs/install/)

    ### Dependencies for browser tests

    You will need additional dependencies if you want to test your frontend using [LuckyFlow](#{Guides::Frontend::Testing.path}),
    see the [Testing HTML and Interactivity](#{Guides::Frontend::Testing.path}) guide for details.

    ## Install Lucky CLI

    Once the required dependencies are installed, set up Lucky for your system.

    ### On macOS

    * Install [Homebrew](https://brew.sh/)
    * Run `brew tap luckyframework/homebrew-lucky`
    * Run `brew install lucky`
    * Make sure [Postgres CLI tools](https://postgresapp.com/documentation/cli-tools.html)
      are installed if you're using Postgres.app


    ### On Linux

    * `git clone` the CLI repo at https://github.com/luckyframework/lucky_cli
    * cd into the newly cloned directory
    * Check out latest [released version](https://github.com/luckyframework/lucky_cli/releases) `git checkout #{LuckyCliVersion.current_tag}`
    * Run `shards install`
    * Run `crystal build src/lucky.cr`
    * Move the generated `lucky` binary to your path. Most of the time you can move
      it to `/usr/local/bin` and it should work: `mv lucky /usr/local/bin`.

    If you needed different steps, please help contribute to this section by
    [editing this page on GitHub](https://github.com/luckyframework/website/blob/master/src/actions/guides/getting-started/installing.cr).
    MD
  end
end
