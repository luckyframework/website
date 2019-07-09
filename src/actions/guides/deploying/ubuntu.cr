class Guides::Deploying::Ubuntu < GuideAction
  guide_route "/deploying/ubuntu"

  def self.title
    "Deploying to an Ubuntu server"
  end

  def markdown
    <<-MD
    ## Prerequisites 

    What you will need:

    * A server with Ubuntu Linux (
      this guide assumes 18.04 but should work for
      other versions a well)
    * SSH access to the server, either as `root` user
      or a user with `sudo` rights (preferred)
    * A lucky app with an awesome name. Replace
      `<yourapp>` in the following instructions with
      that name.
    * A domain name. While lucky apps can be deployed
      in a "subdirectory" of a domain, they work best
      when installed at the root of the domain.
      Replace `<yourdomain>` in the following
      instructions with that domain name.

    ## Install required dependencies

    * Follow the
      [official installation instructions](https://crystal-lang.org/reference/installation/on_debian_and_ubuntu.html)
      to install Crystal. Also install the mentioned 
      optional (but recommended) packages.
      (Please note that even if you do not plan to
      compile code on your server, you still need
      to install Crystal, because you need its runtime.)
    * Follow the [installation instructions](https://yarnpkg.com/lang/en/docs/install/#debian-stable) to install yarn
      (This is optional and only needed if you
      plan to compile assets on the server.)
    * Install PostgreSQL
      ```bash
      sudo apt install postgresql
      ```
    * Install git
      ```bash
      sudo apt install git
      ```
      (This is optional and only needed if you
      plan to deploy source code from a git
      repository.)

    ## Add a deployment user

    While not strictly necessary, it is highly
    recommended to create a dedicated user to
    deploy your app. E.g.:

    ```bash
    sudo adduser deploy
    ```

    Remember to create/edit `/home/deploy/.ssh/authorized_keys`
    if you want to SSH into the machine as the
    deploy user via public key authentication.
    If you set a password in the previous step,
    you could use `ssh-copy-id deploy@<yourserver>`
    to copy you public key(s).

    ## Add a directory for your app

    Feel free to choose whatever location you
    prefer for your app. Many people like to
    put it in `/srv`, but some follow the
    Debian/Ubuntu standard for static html and
    use `/var/www`. Others simply use a directory
    in `/home/deploy`. For the remainder of this
    guide, we use `/srv/<yourapp>` as an example:

    ```bash
    sudo mkdir /srv/<yourapp>
    chown deploy:deploy /srv/<yourapp>
    ```

    ## Create a PostgreSQL database

    Management of PostgreSQL on Debian/Ubuntu
    is usually performed as the `postgres` user.

    Use

    ```bash
    sudo su - postgres
    ```

    to become the `postgres` user and create a
    new database for your app:

    ```bash
    createdb -O deploy <yourapp>_production
    ```

    ## Deploying your app

    There are several approaches to get your
    actuall app on the server depending on
    how automated you want things to be and
    whether you want to compile your code
    on the server or not.

    Here are some examples:

    ### Manual installation using git and compilation on the server

    If you manage your source code with git,
    you might want to simply clone you repository
    on your server:

    ```bash
    git clone <your_repo_url> /srv/<yourapp>
    ```

    On subsequent deployments you can then simply
    use `git pull` to get the latest code or
    `git fetch` followed by `git checkout` to
    check out a specific tag or branch.

    Once you have the code you want to deploy
    you need to install / update dependencies:

    ```bash
    yarn install
    shards install
    ```

    Then first compile your assets for production
    use:

    ```bash
    yarn prod
    ```

    And finally your lucky app:

    ```bash
    crystal build --release src/start_server.cr
    ```

    After every deploy you should run your
    migrations:

    ```bash
    crystal run tasks.cr -- db.migrate
    ```

    You could skip this part if you did not
    add any migrations, but the task is smart
    enough to notice this anyway. So it is
    better to get in the habit to run it
    every time, so not to forget it when it
    is really needed.

    If you are on your first install, we
    will worry about starting the server
    later. On subsequent deployments you
    will need to trigger a restart:

    ```bash
    sudo service <yourapp> restart
    ```

    ### Manual installation using local compilation and scp to the server

    This works very much like compilation
    on the server, so please read the instructions
    above first.

    The important differences are, that you do
    not need git on the server, and you run
    `yarn prod` and `crystal build --release src/start_server.cr`
    on your local machine.

    Afterwards you simply copy your working
    directory over to the server:

    ```bash
    scp -r . deploy@<yourdomain>:/srv/<yourapp>
    ```

    The you ssh into your server and run the
    migrations and possibly restart your
    server as explained above.

    (In theory it would be possible to only
    copy the generated binary and assets. But
    you would also need to compile and copy
    the `db.migrate` task. This is left as an
    excercise.)

    ### Automated deployment using Capistrano

    capistrano is a ruby tool to automate
    deployments of code hosted in a VCS such
    as git.

    While it is mainly used to deploy
    "Ruby on Rails" apps, most of its built-in
    steps are generic, and lucky specific ones
    can be added easily.

    You need a recent version of ruby and
    bundler installed.
    
    In your project's directory run

    ```bash
    bundle init
    ```

    to create an empty `Gemfile`. Add the
    following line to this file:

    ```ruby
    gem "capistrano"
    ```

    Afterwards run

    ```bash
    bundle install
    ```

    to install capistrano. Once the
    installation is finished, you can
    run

    ```bash
    bundle exec cap install
    ```

    to create the necessary config files
    for capistrano. You can remove `config/deploy/stanging.rb`
    and `lib/capistrano/tasks` if you
    do not plan to use them (i.e. you do
    not have a seperate staging server
    and/or do not want to define
    custom tasks in seperate files).

    Adjust `Capfile` to your liking in case
    you use a different VCS than git.

    In `config/deploy/production.rb` add
    the name of your server:

    ```ruby
    server "<yourdomain>", user: "deploy", roles: %w{app db web}
    ```

    Adjust `config/deploy.rb` to look
    something like:

    ```ruby
    lock "~> 3.11.0"
    set :application, "<yourapp>"
    set :repo_url, "<your_repo_url>"
    set :deploy_to, "/srv/<yourapp>"

    namespace :deploy do
      after :updating, :compile do
        on roles(:app) do
          within release_path do
            execute :yarn, :install
            execute :yarn, :prod
            execute :shards, :install
            execute :crystal, :build, "--release", "src/start_server.cr"
          end
        end
      end

      after :compile, :migrate do
        on roles(:db) do
          within release_path do
            env = {
              "LUCKY_ENV" => "production",
              "DATABASE_URL" => "postgres:///<yourapp>_production"
            }
            with(env) do
              execute :crystal, "tasks.cr", "-- db.migrate"
            end
          end
        end
      end

      after :finished, :restart do
        on roles(:app) do
          execute :sudo, "/usr/sbin/service <yourapp> restart"
        end
      end
    end
    ```

    Note that the `restart` task requires
    that your `deploy` user has `sudo` rights
    to execute the given command without
    giving a password. It is probably not
    a good idea to give passwordless `sudo`
    rights for everything. Luckily, `sudo`
    lets you restrict access to a specific
    command. Just add the following line to
    `/etc/sudoers`:

    ```
    deploy  ALL=NOPASSWD: /usr/sbin/service <yourapp> restart
    ```

    ## Creating a systemd unit file for your app

    Modern versions of Ubuntu use `systemd`
    as init and process supervisor. Systemd
    can take care of starting you app and even
    restarting it in case of crashes.

    To start with, you could create a "unit file"
    in `/etc/systemd/system/<yourapp>.service` with
    the following content:

    ```
    [Unit]
    Description=Awesome description of <yourapp>
    After=nginx.service

    [Service]
    Type=simple
    User=deploy
    Environment="LUCKY_ENV=production"
    Environment="SECRET_KEY_BASE=<random unique key>"
    Environment="DATABASE_URL=postgres:///<yourapp>_production"
    Environment="HOST=127.0.0.1"
    Environment="PORT=5000"
    Environment="APP_DOMAIN=https://<yourdomain>"
    WorkingDirectory=/srv/<yourapp>
    ExecStart=/srv/<yourapp>/start_server
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    ```

    Take special note of the environment variables:

    * **LUCKY_ENV**

      This tells lucky to run in `production` mode.
    * **SECRET_KEY_BASE**

      This is a secrect key that should be random and unique to your
      server. You can use the `gen.secrect_key` task to generate
      a suitable string:

      ```bash
      lucky gen.secret_key
      ```
    * **DATABASE_URL**

      This tells lucky where to find your database.
    * **APP_DOMAIN**

      lucky uses this setting to generate full URLs.
    * **HOST** and **PORT**

      This tells our server on which IP address and port to listen on.
      We set this to localhost to not expose the lucky app directly
      to the internet. Instead we will put a "proper" webserver in
      front of it, that can also handle TLS/SSL among other things.

    After creating a new unit file, or editing
    an existing one, you need to run the
    following command for `systemd` to pick
    up the changes:

    ```bash
    sudo systemctl daemon-reload
    ```

    Then you should be able to start your
    app for the first time:

    ```bash
    sudo service <yourapp> start
    ```

    This would be a good time to further
    read about `systemd`s
    [unit files](http://0pointer.de/public/systemd-man/systemd.unit.html)
    and
    [service definitions](http://0pointer.de/public/systemd-man/systemd.service.html)
    just in case you would like to make some
    customizations.

    ## Install and configure nginx as a frontend webserver

    Note: nginx is but one of many options
    for a frontend webserver. We use it as
    an example here, because it is widely
    used and comparatively easy to configure
    for our use-case.

    Install nginx:

    ```bash
    sudo apt install nginx
    ```

    Create a new configuration file in
    `/etc/nginx/sites-available/<yourapp>.conf`
    with the following content:

    ```
    upstream lucky {
            server localhost:5000;
    }

    server {
            listen 80 default_server;
            listen [::]:80 default_server;

            server_name <yourdomain>;

            return 301 https://$host$request_uri;
    }

    server {
            listen 443 ssl default_server;
            listen [::]:443 ssl default_server;

            root /srv/<yourapp>/public;

            server_name <yourapp>;

            location / {
                    proxy_pass http://lucky;
            }

            ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem
            ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key
    }
    ```

    Create a symbolic link for your configuration
    in `/etc/nginx/sites-enabled`:

    ```bash
    sudo ln -s /etc/sites-available/<yourapp>.conf /etc/sites-enabled/<yourapp>.conf
    ```

    Optional: Remove the `default` site's config from `/etc/sites-enabled`.

    Restart nginx:

    ```bash
    sudo service nginx restart
    ```

    ## Possible next steps

    * Acquire a valid SSL certificate
      (possibly using [Let's Encrypt](https://letsencrypt.org))
    * Configure Dexter, lucky's logger,  to log
      into a file and set up `logrotate` to rotate
      it at regular intervals
    MD
  end
end
