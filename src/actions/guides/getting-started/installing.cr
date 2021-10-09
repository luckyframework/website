class Guides::GettingStarted::Installing < GuideAction
  ANCHOR_INSTALL_REQUIRED_DEPENDENCIES = "perma-install-required-dependencies"
  ANCHOR_POSTGRESQL                    = "perma-install-postgres"
  ANCHOR_PROC_MANAGER                  = "perma-install-process-manager"
  ANCHOR_NODE                          = "perma-install-node"
  guide_route "/getting-started/installing"

  def self.title
    "Installing Lucky"
  end

  def markdown : String
    <<-MD
    #{permalink(ANCHOR_INSTALL_REQUIRED_DEPENDENCIES)}
    ## MacOS requirements

    ### 1. Install Homebrew

    Installation instructions from the [Homebrew website](https://brew.sh/)

    ```plain
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    ```

    ### 2. Install OpenSSL

    ```plain
    brew install openssl
    ```

    ### 3. Configure SSL for Crystal

    You'll need to tell Crystal how to find OpenSSL by adding an `export`
    to your `~/.bash_profile` or `~/.zshrc`.

    > You can run `echo $SHELL` in your terminal if you're not sure whether you
      are using ZSH or Bash.

    **For ZSH (the default as of macOS Catalina):**

    ```plain
    echo 'export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig' >>~/.zshrc
    ```

    **For Bash:**

    ```plain
    echo 'export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig' >>~/.bash_profile
    ```

    > If you get an error like this: "Package libssl/libcrypto was not found in the
      pkg-config search path" then be sure to run this step so that
      Crystal knows where OpenSSL is located.

    ## Linux requirements

    ### Debian

    ```plain
    apt-get install libc6-dev libevent-dev libpcre2-dev libpng-dev libssl-dev libyaml-dev zlib1g-dev
    ```

    ### Ubuntu

    ```plain
    apt-get install libc6-dev libevent-dev libpcre2-dev libpcre3-dev libpng-dev libssl-dev libyaml-dev zlib1g-dev
    ```

    ### Fedora (28)

    ```plain
    dnf install glibc-devel libevent-devel pcre2-devel openssl-devel libyaml-devel zlib-devel libpng-devel
    ```

    ## Crystal Version

    Lucky supports Crystal `>= #{LuckyCliVersion.min_compatible_crystal_version}`, `<= #{LuckyCliVersion.max_compatible_crystal_version}`

    ### 1. Install Crystal

    **Using asdf version manager:**

    We recommend using a version manager to make sure the correct version of
    Crystal is used with Lucky.

    * [Install asdf](https://asdf-vm.com/#/core-manage-asdf)
    * Install the [asdf-crystal](https://github.com/marciogm/asdf-crystal) plugin:

    ```plain
    asdf plugin-add crystal https://github.com/asdf-community/asdf-crystal.git
    ```

    * Set up `asdf` so it uses the `.crystal-version` file to determine which version to use:

    ```plain
    echo "legacy_version_file = yes" >>~/.asdfrc
    ```

    * Install Crystal with `asdf`.

    ```plain
    asdf install crystal #{LuckyCliVersion.min_compatible_crystal_version}
    ```

    * See which version of crystal was installed

    ```plain
    asdf list crystal
    ```

    * Set global version of crystal to that version (#{LuckyCliVersion.min_compatible_crystal_version} is used as an example)

    ```plain
    asdf global crystal #{LuckyCliVersion.min_compatible_crystal_version}
    ```

    **Or, install Crystal without a version manager**

    If you can't get asdf installed or don't want to use a version manager,
    you can [install Crystal without a version manager](https://crystal-lang.org/install/).

    ### 2. Check installation

    ```plain
    crystal -v
    ```

    Should return at least `#{LuckyCliVersion.min_compatible_crystal_version}`

    ## Install Lucky CLI on macOS

    Once the required dependencies above are installed, set up Lucky for your system.

    ### 1. Add the Lucky tap to Homebrew

    ```plain
    brew tap luckyframework/homebrew-lucky
    ```

    ### 2. Install the Lucky CLI with Homebrew

    ```plain
    brew install lucky
    ```

    ### 3. Check installation

    Let's make sure the Lucky CLI installed correctly:

    ```plain
    lucky -v
    ```

    This should return `#{LuckyCliVersion.current_version}`

    ## Install Lucky CLI on Linux

    ### 1. Clone the CLI repo

    ```plain
    git clone https://github.com/luckyframework/lucky_cli
    ```

    ### 2. Change into the newly cloned directory

    ```plain
    cd lucky_cli
    ```

    ### 3. Check out the latest released version

    ```plain
    git checkout #{LuckyCliVersion.current_tag}
    ```

    ### 4. Install shards

    We call packages/libraries in Crystal "shards". Let's install the shards that Lucky CLI needs:

    ```plain
    shards install
    ```

    ### 5. Build the CLI

    ```plain
    crystal build src/lucky.cr
    ```

    ### 6. Move the generated binary to your path

    This will let you use `lucky` from the command line.

    ```plain
    mv lucky /usr/local/bin
    ```

    ### 7. Check installation

    Let's make sure the Lucky CLI installed correctly:

    ```plain
    lucky -v
    ```

    This should return `#{LuckyCliVersion.current_version}`

    #{permalink(ANCHOR_PROC_MANAGER)}
    ## Process manager

    Lucky uses a process manager to watch assets and start the server in development.

    Install one of these process managers: [Overmind (recommended)](https://github.com/DarthSim/overmind#installation),
    [Heroku CLI (great if you plan to use Heroku to deploy)](https://devcenter.heroku.com/articles/heroku-cli#download-and-install),
    [forego](https://github.com/ddollar/forego#installation),
    or [foreman](https://github.com/ddollar/foreman#installation).

    > By default Lucky creates a `Procfile.dev` that  defines  what processes should be started when running `lucky dev`.
    > You can modify the `Procfile.dev` to start other processes like running
    > background jobs.

    > For WSL users on Windows, Overmind is not recommended due to [compatibility issues](https://github.com/DarthSim/overmind/issues/88).

    #{permalink(ANCHOR_POSTGRESQL)}
    ## Postgres database

    ### 1. Install Postgres

    Lucky uses Postgres for its database. Install Postgres ([macOS](https://postgresapp.com)/[Others](https://wiki.postgresql.org/wiki/Detailed_installation_guides))

    ### 1a. (macOS only) Ensure Postgres CLI tools installed

    If you're using [Postgres.app](https://postgresapp.com) on macOS make sure
    [Postgres CLI tools](https://postgresapp.com/documentation/cli-tools.html) are installed

    ```plain
    sudo mkdir -p /etc/paths.d &&
      echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
    ```

    There are other installation methods available in [Postgres CLI tools docs](https://postgresapp.com/documentation/cli-tools.html)

    ### 1b. (Linux only) Password-less logins for local development

    Homebrew installed PostgreSQL on macOS are configured by default to allow password-less logins.  But for Linux, if you wish to
    use PostgreSQL without a password, you'll need to ensure your user is added to the `pg_hba.conf` file with `trust` method specified.
    We recommend adding this entry right after the `postgres` user entry:

    ```plain
    local   all             postgres                                peer

    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    host    all             your_username   127.0.0.1/32            trust  # Add this line
    ```

    > `your_username` is the local user you're logging into the DBMS with.  Change as appropriate.

    Visit [PostgreSQL Authentication Methods](https://www.postgresql.org/docs/12/auth-methods.html) to learn more more about
    available authentication methods and how to configure them for PostgreSQL.

    > Restart the `postgresql` service to activate the configuration changes.

    ### 2. Ensure Postgres CLI tools installed

    First open a new session to reload your terminal, then:

    ```plain
    psql --version
    ```

    Should return `psql (PostgreSQL) 10.x` or higher.

    #{permalink(ANCHOR_NODE)}
    ## Node and Yarn (optional)

    > You can skip this if you only plan to only build APIs.

    ### 1. Install

    * [Node](https://nodejs.org/en/download/). Requires at least v11
    * [Yarn](https://yarnpkg.com/lang/en/docs/install/)

    ### 2. Check installation

    ```plain
    node -v
    yarn -v
    ```

    Node should return greater than v11. Yarn should return greater than 1.x.

    ## Chrome Browser (optional)

    > You can skip this if you only plan to only build APIs.

    Lucky uses Chromedriver for [Testing HTML](#{Guides::Testing::HtmlAndInteractivity.path}).
    The Chromedriver utility will be installed for you once you start running your tests; however,
    it requires the Chrome browser to be installed on your machine. If you don't already have it
    installed, you can install it directly from [Google](https://www.google.com/chrome/).

    > You can also use an alternative chrome-like browser (e.g. Brave, Edge, etc...). See the
    > [Flow](#{Guides::Testing::HtmlAndInteractivity.path}) guides for customization options.

    MD
  end
end
