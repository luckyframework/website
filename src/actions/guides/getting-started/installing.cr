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

    ```bash
    crystal -v
    ```

    Should return between `#{LuckyCliVersion.min_compatible_crystal_version}` and `#{LuckyCliVersion.max_compatible_crystal_version}`

    ## macOS (Apple Silicon) requirements

    ### 1. Install Homebrew

    Installation instructions from the [Homebrew website](https://brew.sh/)

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

    ## macOS (Intel) requirements

    ### 1. Install Homebrew

    Installation instructions from the [Homebrew website](https://brew.sh/)

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

    ### 2. Install OpenSSL

    ```bash
    brew install openssl
    ```

    ### 3. Configure SSL for Crystal

    Add the following line to your shell configuration file. This will let Crystal know where to find OpenSSL.

    > You can run `echo $SHELL` in your terminal if you're not sure whether you
      are using ZSH, Bash or Fish.

    **For ZSH (the default as of macOS Catalina):**

    macOS (Apple Silicon)
    ```bash
    echo 'export PKG_CONFIG_PATH=/opt/homebrew/opt/openssl/lib/pkgconfig' >>~/.zshrc
    ```

    macOS (Intel)
    ```bash
    echo 'export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig' >>~/.zshrc
    ```

    **For Bash:**

    macOS (Apple Silicon)
    ```bash
    echo 'export PKG_CONFIG_PATH=/opt/homebrew/opt/openssl/lib/pkgconfig' >>~/.bash_profile
    ```

    macOS (Intel)
    ```bash
    echo 'export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig' >>~/.bash_profile
    ```

    **For Fish:**

    macOS (Apple Silicon)
    ```bash
    echo 'set -gx PKG_CONFIG_PATH /opt/homebrew/opt/openssl/lib/pkgconfig' >> ~/.config/fish/config.fish
    ```

    macOS (Intel)
    ```bash
    echo 'set -gx PKG_CONFIG_PATH /usr/local/opt/openssl/lib/pkgconfig' >> ~/.config/fish/config.fish
    ```

    > If you get an error like this: "Package libssl/libcrypto was not found in the
      pkg-config search path" then be sure to run this step so that
      Crystal knows where OpenSSL is located.

    ## Linux / WSL2 requirements

    These are additional dependencies you will need in order to boot your Lucky application.

    ### Debian

    ```bash
    apt-get install libc6-dev libevent-dev libpcre2-dev libpng-dev libssl-dev libyaml-dev zlib1g-dev
    ```

    ### Ubuntu

    ```bash
    apt-get install libc6-dev libevent-dev libpcre2-dev libpcre3-dev libpng-dev libssl-dev libyaml-dev zlib1g-dev
    ```

    ### Fedora (28)

    ```bash
    dnf install glibc-devel libevent-devel pcre2-devel openssl-devel libyaml-devel zlib-devel libpng-devel
    ```

    ## Windows requirements

    Please see the requirements to install [Crystal on Windows](https://crystal-lang.org/install/on_windows/) first.

    ### Install with Scoop

    If you're using [Scoop](https://scoop.sh/) on Windows, you can install the Lucky CLI using our Scoop package.

    ```bash
    scoop bucket add lucky https://github.com/luckyframework/scoop-bucket
    scoop install lucky
    ```

    ## Install Lucky CLI with Homebrew

    Once the required dependencies above are installed, set up Lucky for your system.

    ### 1. Install the Lucky CLI with Homebrew

    ```bash
    brew install luckyframework/homebrew-lucky/lucky
    ```

    ### 3. Check installation

    Let's make sure the Lucky CLI installed correctly:

    ```bash
    lucky -v
    ```

    This should return `#{LuckyCliVersion.current_version}`

    ## Install Lucky CLI Manually

    ### 1. Clone the CLI repo

    ```bash
    git clone https://github.com/luckyframework/lucky_cli
    ```

    ### 2. Change into the newly cloned directory

    ```bash
    cd lucky_cli
    ```

    ### 3. Check out the latest released version

    ```bash
    git checkout #{LuckyCliVersion.current_tag}
    ```

    ### 4. Install shards

    We call packages/libraries in Crystal "shards". Let's install the shards that Lucky CLI needs:

    ```bash
    shards install --without-development
    ```

    ### 5. Build the CLI

    ```bash
    shards build --production
    ```

    ### 6. Move the generated binary to your path

    This will let you use `lucky` from the command line.
    ```bash
    cp bin/lucky /usr/local/bin
    ```
    Or anywhere else you deem fit

    ### 7. Check installation

    Let's make sure the Lucky CLI installed correctly:

    ```bash
    lucky -v
    ```

    This should return `#{LuckyCliVersion.current_version}`

    #{permalink(ANCHOR_POSTGRESQL)}
    ## Postgres database (optional)

    > You can skip this if you don't need database. Many sites (including this one) have no need for a database. In some cases,
    your data comes from a 3rd party API, or maybe you need a custom database engine other than PostgreSQL.

    > You can skip this if you plan to use Lucky with a Postgres docker container. Please note that a docker-compose configuration (with Postgres included)
    is provided out of the box when you start your project with `lucky init`.

    ### 1. Install Postgres

    Lucky uses Postgres for its database. Install Postgres ([macOS](https://postgresapp.com)/[Others](https://wiki.postgresql.org/wiki/Detailed_installation_guides))

    ### 1a. (macOS only) Ensure Postgres CLI tools installed

    If you're using [Postgres.app](https://postgresapp.com) on macOS make sure
    [Postgres CLI tools](https://postgresapp.com/documentation/cli-tools.html) are installed

    ```bash
    sudo mkdir -p /etc/paths.d &&
      echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
    ```

    There are other installation methods available in [Postgres CLI tools docs](https://postgresapp.com/documentation/cli-tools.html)

    ### 1b. (Linux only) Configure PostgreSQL authentication trust for local development

    Homebrew installed PostgreSQL on macOS are configured by default to allow password-less logins. But for Linux, if you wish to
    use PostgreSQL without a password, you'll need to ensure your `pg_hba.conf` file is updated.
    We recommend adding this entry right after the `postgres` user entry:

    ```bash
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    # "local" is for Unix domain socket connections only
    local   all             all                                     trust
    # IPv4 local connections:
    host    all             all             127.0.0.1/32            trust
    # IPv6 local connections:
    host    all             all             ::1/128                 trust
    ```

    Visit [PostgreSQL Authentication Methods](https://www.postgresql.org/docs/14/auth-methods.html) to learn
    more more about available authentication methods and how to configure them for PostgreSQL.

    > Restart the `postgresql` service to activate the configuration changes.

    ```bash
    sudo systemctl restart postgresql
    ```

    ### 2. Verify PostgreSQL CLI client (psql) is installed

    First open a new session to reload your terminal, then:

    ```bash
    psql --version
    ```

    Should return `psql (PostgreSQL) 10.x` or higher.

    ### 3. Create a database user and set a password

    You will need to create a database user with proper permissions to allow Lucky to manage the application database.
    There are several ways to accomplish this, but fortunatly PostgreSQL ships several command line tools to simplify
    this step. You will need to become the "postgres" user:
    ```bash
    sudo su - postgres
    ```

    Now create the user, and set the roles `createrole`, `superuser`, `createdb` then enter a password. In
    this example below, we will create a user named "lucky" and set a password of "lucky".
    ```bash
    createuser -dsrP lucky
    ```

    > Lucky versions 1.1.0 - 1.2.0 expects an existing database with the same name as the user you created in the
    > previous step. The setup script and database tasks will fail after init if it does not exist. This requirement
    > wil be removed in the next release.
    ```bash
    createdb -O lucky lucky
    ```

    Return back to your normal user.
    ```bash
    exit
    ```

    Now test the user can connect to the local postgres datbabase, enter the password for the user you just created when prompted.
    ```bash
    psql -h localhost -U lucky -W postgres
    ```

    If successful, you should see the following output, then type `\\q` and hit `enter` to quit the client.
    ```
    > psql -h localhost -U lucky -W postgres

    Password:
    psql (14.12 (Ubuntu 14.12-0ubuntu0.22.04.1))
    SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
    Type "help" for help.

    postgres=# \\q
    ```

    #{permalink(ANCHOR_NODE)}
    ## Node and Yarn (optional)

    > You can skip this if you only plan to build APIs.

    ### 1. Install

    * [Node](https://nodejs.org/en/download/). Requires at least v11
    * [Yarn](https://yarnpkg.com/lang/en/docs/install/)

    ### 2. Check installation

    ```bash
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
