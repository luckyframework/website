class Guides::Deploying::Ubuntu < GuideAction
  guide_route "/deploying/ubuntu"

  def self.title
    "Deploying to an Ubuntu server"
  end

  def markdown : String
    <<-MD
    ## Prerequisites

    What you will need:

    * A server with Ubuntu Linux (
      this guide assumes 18.04 but should work for
      other versions a well)
    * SSH access to the server with `sudo` permissions
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
      [official installation instructions](https://crystal-lang.org/install/on_ubuntu/)
      to install Crystal. Also install the mentioned
      optional (but recommended) packages.
    * Follow the [installation instructions](https://yarnpkg.com/lang/en/docs/install/#debian-stable) to install yarn
    * Install PostgreSQL
      ```bash
      sudo apt install postgresql
      ```
    * Install git
      ```bash
      sudo apt install git
      ```

    ## Add a deployment user

    Create a new user. This will be the user your
    app will run as.

    ```bash
    sudo adduser --disabled-login deploy
    ```

    ## Add a directory for your app

    This will hold your application's code:

    ```bash
    sudo mkdir /srv/<yourapp>
    sudo chown deploy:deploy /srv/<yourapp>
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

    Become the `deploy` user:

    ```bash
    sudo su - deploy
    ```

    And then check out your code:

    ```bash
    git clone <your_repo_url> /srv/<yourapp>
    cd /srv/<yourapp>
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

    > Note: You may have to specify the `DATABASE_URL` and any other environment
    > variables your app uses before you can migrate. Only `DATABASE_URL` needs to be
    > real. The rest can be blank. For example if your app uses `API_KEY` and
    > `SUPPORT_EMAIL` environment variables, you can add them before running
    > crystal like so:
    >
    > ```bash
    > API_KEY= SUPPORT_EMAIL= DATABASE_URL=postgresql://<username>:<password>@127.0.0.1/<appname>_production crystal run tasks.cr -- db.migrate
    >```

    Exit your session as the `deploy` user, either
    with `CTRL-D` or by entering `exit`.

    If you are on your first install, we
    will worry about starting the server
    later. On subsequent deployments you
    will need to trigger a restart:

    ```bash
    sudo service <yourapp> restart
    ```

    ## Creating a systemd unit file for your app

    Modern versions of Ubuntu use `systemd`
    as init system and process supervisor. Systemd
    can take care of starting your app and even
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
    Environment="SEND_GRID_KEY=<SendGrid key>"
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

      This is a secret key that should be random and unique to your
      server. You can use the `gen.secret_key` task to generate
      a suitable string:

      ```bash
      lucky gen.secret_key
      ```
    * **SEND_GRID_KEY**

    This is your SendGrid key to be able to send emails. Set it to
    'unused' if not sending emails.
    
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

            ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
            ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
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
