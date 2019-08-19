class Guides::GettingStarted::Installing < GuideAction
  ANCHOR_INSTALL_REQUIRED_DEPENDENCIES = "perma-install-required-dependencies"
  guide_route "/getting-started/installing"

  def self.title
    "Installing Lucky"
  end

  def markdown
    <<-MD
    #{permalink(ANCHOR_INSTALL_REQUIRED_DEPENDENCIES)}
    ## Install Required Dependencies

    To get Lucky, you need to install these first.

    * Install one of these process managers: [Overmind (recommended)](https://github.com/DarthSim/overmind#installation),
      [Heroku CLI (great if you plan to use Heroku to deploy)](https://devcenter.heroku.com/articles/heroku-cli#download-and-install),
      [forego](https://github.com/ddollar/forego#installation),
      or [foreman](https://github.com/ddollar/foreman#installation).
    * [Crystal v0.30](https://crystal-lang.org/reference/installation/)
    * Postgres ([macOS](https://postgresapp.com)/[Others](https://wiki.postgresql.org/wiki/Detailed_installation_guides))

    ### Debian and Fedora dependencies

    * Debian (Ubuntu should be similar): run `apt-get install libc6-dev libevent-dev libpcre2-dev libpng-dev libssl1.0-dev libyaml-dev zlib1g-dev`
    * Fedora (28): run `dnf install glibc-devel libevent-devel pcre2-devel openssl-devel libyaml-devel zlib-devel libpng-devel`. libpng-devel is for Laravel Mix

    ### For building assets (skip if building APIs)

    * [Node](https://nodejs.org/en/download/). Requires at least v6
    * [Yarn](https://yarnpkg.com/lang/en/docs/install/)

    ## Install Lucky CLI

    Once the required dependencies are installed, set up Lucky for your system.

    ### On macOS

    * Install [Homebrew](https://brew.sh/)
    * Run `brew install openssl` to make sure you have OpenSSL
    * Run `brew tap luckyframework/homebrew-lucky`
    * Run `brew install lucky`
    * Make sure [Postgres CLI tools](https://postgresapp.com/documentation/cli-tools.html)
      are installed if you're using Postgres.app
    * If you are on macOS High Sierra you need to add `export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig`
    to your `~/.bash_profile` or `~/.zshrc`

    > If you get an error like this: `Package libssl/libcrypto was not found in the
    pkg-config search path` then be sure to run the last step listed above so that
    Crystal knows where OpenSSL is located.

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
