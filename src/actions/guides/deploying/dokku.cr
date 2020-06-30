class Guides::Deploying::Dokku < GuideAction
  guide_route "/deploying/dokku"

  def self.title
    "Deploying to Dokku"
  end

  def markdown : String
    <<-MD
    ## Prerequisites

    You will need a server with Dokku installed and SSH access. See the Dokku [Getting Started](http://dokku.viewdocs.io/dokku/getting-started/installation/#installing-the-latest-stable-version) guide for more details.

    ## Setting up the Dokku configuration

    SSH into your server to get it ready for deployment.

    ```
    ssh root@ip
    ```

    In the following commands replace `app.example.com` with your domain or subdomain. Replace `exampledb` with your preferred database name.

    This will create the initial app container in Dokku, create the database, and link them both together. The last three lines set environment variables for the Lucky app. The first will tell Lucky to run the app in `production` mode, the second will tell Lucky what the app URL is, and the third will tell the app to run on port 5000 which Dokku will connect with Nginx to expose to the world.

    ```
    dokku apps:create app.example.com
    dokku postgres:create exampledb
    dokku postgres:link exampledb app.example.com
    dokku config:set app.example.com LUCKY_ENV=production
    dokku config:set app.example.com APP_DOMAIN=app.example.com
    dokku config:set app.example.com PORT=5000
    ```

    There's a few more configuration details that need to be set. First, you'll need to tell Lucky the database details that are set in Dokku. Run the below command to get the database URL.

    ```
    dokku postgres:info exampledb
    ```

    Set the `DATABASE_URL` environment variable from the above output.

    ```
    dokku config:set app.example.com DATABASE_URL=postgres://...
    ```

    Next, Lucky needs a secret key environment variable. In your app directory on your local machine run the following command which will generate a secure key.

    ```
    lucky gen.secret_key
    ```

    Then, back on your remote Dokku server add it to the `SECRET_KEY_BASE` environment variable.

    ```
    dokku config:set app.example.com SECRET_KEY_BASE=...
    ```

    If you're planning to send emails through the app you'll also need to set `SEND_GRID_KEY` key, otherwise, change `config/email.cr` to use `Carbon::DevAdapter.new` in production (and make sure to commit!)

    ```
    dokku config:set app.example.com SEND_GRID_KEY=...
    ```

    Your server is almost ready for deployment. If you're using a server with 2GB of RAM or less, you'll need to set up a Swap. Without it the deployment process will most likely run into memory issues. [Checkout this tutorial for setting up a Swap](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04). A 1G Swap should be more than enough.

    ## Ready the app for deployment

    Back in your local app add a new file called `.buildpacks` with the following contents. This is the same buildpacks used for the Heroku deployment.

    ```
    https://github.com/heroku/heroku-buildpack-nodejs
    https://github.com/luckyframework/heroku-buildpack-crystal
    ```

    ## First deployment

    Make a new commit. Finally you're ready to deploy. Run the following commands locally. The first will add your server as a remote origin for your git repo. The second will push the code to the server.

    ```
    git remote add dokku dokku@ip:app.example.com
    git push dokku master
    ```

    ## Set up SSL

    Dokku lets you easily set up a Lets Encrypt SSL certificate. Run the following commands to do so

    ```
    dokku config:set --no-restart app.example.com DOKKU_LETSENCRYPT_EMAIL=your.email@example.com
    dokku letsencrypt app.example.com
    ```

    That's all there is to it! Each time you push to your Dokku server your app will update and migrations will be ran automatically.

    MD
  end
end
