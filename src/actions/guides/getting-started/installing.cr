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
    ## Crystal Version

    You will need Crystal installed for local development. Make sure to install all of Crystal's
    dependencies for your system.

    Lucky supports Crystal `>= #{LuckyCliVersion.min_compatible_crystal_version}`, `<= #{LuckyCliVersion.max_compatible_crystal_version}`

    ### 1. Install Crystal

    Follow the [Installing Crystal](https://crystal-lang.org/install/) instructions page
    for your specific system.

    ### 2. Check installation

    ```plain
    crystal -v
    ```

    Should return between `#{LuckyCliVersion.min_compatible_crystal_version}` and `#{LuckyCliVersion.max_compatible_crystal_version}`

    ## macOS (M1) requirements

    ### 1. Install Homebrew

    Installation instructions from the [Homebrew website](https://brew.sh/)

    ```plain
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

    ## macOS (Intel) requirements

    ### 1. Install Homebrew

    Installation instructions from the [Homebrew website](https://brew.sh/)

    ```plain
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
    
    macOS (Intel)
    ```plain
    echo 'export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig' >>~/.zshrc
    ```
    
    macOS (M1)
    ```plain
    echo 'export PKG_CONFIG_PATH=/opt/homebrew/opt/openssl/lib/pkgconfig' >>~/.zshrc
    ```
    
    **For Bash:**

    macOS (Intel)
    ```plain
    echo 'export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig' >>~/.bash_profile
    ```
    
    macOS (M1)
    ```plain
    echo 'export PKG_CONFIG_PATH=/opt/homebrew/opt/openssl/lib/pkgconfig' >>~/.bash_profile
    ```

    > If you get an error like this: "Package libssl/libcrypto was not found in the
      pkg-config search path" then be sure to run this step so that
      Crystal knows where OpenSSL is located.

    ## Linux / WSL2 requirements

    These are additional dependencies you will need in order to boot your Lucky application.

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

    ## Install Lucky CLI with Homebrew

    Once the required dependencies above are installed, set up Lucky for your system.

    ### 1. Install the Lucky CLI with Homebrew

    ```plain
    brew install luckyframework/homebrew-lucky/lucky
    ```

    ### 3. Check installation

    Let's make sure the Lucky CLI installed correctly:

    ```plain
    lucky -v
    ```

    This should return `#{LuckyCliVersion.current_version}`

    ## Install Lucky CLI Manually

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
    shards install --without-development
    ```

    ### 5. Build the CLI

    ```plain
    shards build --production
    ```

    ### 6. Move the generated binary to your path

    This will let you use `lucky` from the command line.

    macOS (Intel)
    ```plain
    cp bin/lucky /usr/local/bin
    ```
    
    macOS (M1)
    ```plain
    cp bin/lucky /opt/homebrew/bin
    ```

    ### 7. Check installation

    Let's make sure the Lucky CLI installed correctly:

    ```plain
    lucky -v
    ```

    This should return `#{LuckyCliVersion.current_version}`

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

    Homebrew installed PostgreSQL on macOS are configured by default to allow password-less logins. But for Linux, if you wish to
    use PostgreSQL without a password, you'll need to ensure your `pg_hba.conf` file is updated.
    We recommend adding this entry right after the `postgres` user entry:

    ```plain
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    # "local" is for Unix domain socket connections only
    local   all             all                                     trust
    # IPv4 local connections:
    host    all             all             127.0.0.1/32            trust
    # IPv6 local connections:
    host    all             all             ::1/128                 trust
    ```

    Visit [PostgreSQL Authentication Methods](https://www.postgresql.org/docs/12/auth-methods.html) to learn
    more more about available authentication methods and how to configure them for PostgreSQL.

    > Restart the `postgresql` service to activate the configuration changes.

    ### 2. Ensure Postgres CLI tools installed

    First open a new session to reload your terminal, then:

    ```plain
    psql --version
    ```

    Should return `psql (PostgreSQL) 10.x` or higher.

    #{permalink(ANCHOR_NODE)}
    ## Node and Yarn (optional)

    > You can skip this if you only plan to build APIs.

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
