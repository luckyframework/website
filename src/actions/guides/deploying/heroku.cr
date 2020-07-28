class Guides::Deploying::Heroku < GuideAction
  guide_route "/deploying/heroku"

  def self.title
    "Deploying to Heroku"
  end

  def markdown : String
    <<-MD
    ## Quickstart

    If you are comfortable with Heroku,
    here are the
    (brief)
    steps you need to get up
    and running:

    If not already created, create an app:

    ```plain
    heroku create <APP_NAME>
    ```

    **Optional**: if you created the app through the dashboard instead of the CLI,
    add a git remote that points to your Heroku app:

    ```plain
    heroku git:remote -a <APP-NAME>
    ```

    Add the following buildpacks in order:

    ```plain
    # Skip this buildpack for API only app. Add this for HTML and Assets
    heroku buildpacks:add https://github.com/heroku/heroku-buildpack-nodejs

    # Then add this for all Lucky apps
    heroku buildpacks:add https://github.com/luckyframework/heroku-buildpack-crystal
    ```

    Set `LUCKY_ENV` to `production`:

    ```plain
    heroku config:set LUCKY_ENV=production
    ```

    Set `SECRET_KEY_BASE`:

    ```plain
    heroku config:set SECRET_KEY_BASE=$(lucky gen.secret_key)
    ```

    Set `APP_DOMAIN`:

    ```plain
    heroku config:set APP_DOMAIN=https://your-domain.com
    ```

    **If you don't have a custom domain** set this to `https://<APP_NAME>.herokuapp.com`.

    Set `SEND_GRID_KEY`:

    ```plain
    heroku config:set SEND_GRID_KEY=<key from sendgrid.com>
    ```

    **If you're not sending emails**, set the key to `unused` or go to `config/email.cr`
    and change the adapter to `Carbon::DevAdapter`.

    Add a [postgresql database](https://elements.heroku.com/addons/heroku-postgresql)
    add-on:

    ```plain
    heroku addons:create heroku-postgresql:hobby-dev
    ```

    Push to Heroku:

    ```plain
    git push heroku master
    ```

    Each step is explained in more detail below.

    ## Getting started

    For those new to the Heroku platform,
    or those that want more guidance,
    we'll walk through the process step-by-step.

    First,
    we'll need to create an account at
    [Heroku](https://www.heroku.com).
    Once that's done,
    create a new app via the
    [Heroku Dashboard](https://dashboard.heroku.com/apps).
    We can give the app a unique name
    or leave it blank
    and Heroku will create one for us.
    For this tutorial,
    we'll use the placeholder `<APP-NAME>`.

    ## Setting up git for Heroku

    The
    [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)
    will let us manage our app from the command line.
    A normal installation of Lucky
    [requires](#{Guides::GettingStarted::Installing.path(anchor: Guides::GettingStarted::Installing::ANCHOR_INSTALL_REQUIRED_DEPENDENCIES)})
    that it's installed,
    so we should already have the `heroku` command.
    The first thing we'll do is to connect our Lucky app to the Heroku app by adding a git remote:

    ```bash
    heroku git:remote -a <APP-NAME>
    ```

    ## Buildpacks

    Most Lucky apps are built with both Crystal
    and Node.js.
    Heroku uses
    [buildpacks](https://devcenter.heroku.com/articles/buildpacks)
    to compile each executable portion of an app.
    The Node.js buildpack must go first so that Heroku can compile the app's assets before Lucky is compiled.
    To enable a Node.js app on Heroku,
    we'll add the
    [official Node.js buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
    to our app:

    ```bash
    heroku buildpacks:add https://github.com/heroku/heroku-buildpack-nodejs
    ```

    While Heroku has a buildpack for Node.js apps,
    it doesn't have one for Crystal apps
    (yet).
    Fortunately for us,
    Lucky has
    [such a buildpack](https://github.com/luckyframework/heroku-buildpack-crystal)!
    We'll add it so Heroku can download
    and install the dependencies for Lucky:

    ```bash
    heroku buildpacks:add https://github.com/luckyframework/heroku-buildpack-crystal
    ```

    ## Adding environment variables

    ### `LUCKY_ENV`

    Lucky needs a couple of environment variables to operate as a production app.
    The first is the `LUCKY_ENV`.
    We'll set it to `production`.
    This will signal to Lucky that it should,
    for example,
    display absolute timestamps in the server log,
    and use additional environment variables for its configuration:

    ```bash
    heroku config:set LUCKY_ENV=production
    ```

    ### `APP_DOMAIN`

    Lucky needs the app's domain when it builds full URLs.

    ```bash
    heroku config:set APP_DOMAIN=https://myapp.com
    ```

    ### `SECRET_KEY_BASE`

    Next,
    we'll generate a secret key for our app.
    Among other things,
    this key will give us a unique value for our site's cookies.
    Once we have our secret key,
    we can set the `SECRET_KEY_BASE` environment variable with that key:

    ```bash
    heroku config:set SECRET_KEY_BASE=$(lucky gen.secret_key)
    ```

    ### `SEND_GRID_KEY` (set to "unused" if not sending emails)

    If you are sending emails, you'll need to sign up for an account and get an
    API key from SendGrid.com. Once you have it we can set the `SECRET_KEY_BASE`
    environment variable:

    ```bash
    heroku config:set SEND_GRID_KEY=<KEY>
    ```

    If you don't need to send emails you can set the value to `unused`.

    Alternatively, you can change the config in `config/email.cr` to use the
    `Carbon::DevAdapter`. When you open the file there
    will be comments showing you how to do this.

    > Read more about [emailing with Carbon](#{Guides::Emails::SendingEmailsWithCarbon.path})

    ## Adding a database

    Heroku offers a
    [free database](https://devcenter.heroku.com/articles/heroku-postgres-plans#hobby-tier)
    add-on with up to 10,000 rows.
    This is almost certainly enough for most hobby projects,
    at least to get started.
    If we need more rows
    or resources,
    they offer
    [upgraded plans](https://elements.heroku.com/addons/heroku-postgresql).
    For this tutorial,
    we're going to stick with the `hobby-dev` plan.

    We'll attach the database add-on to our app:

    ```bash
    heroku addons:create heroku-postgresql:hobby-dev
    ```

    ## Uploading the app

    The last step is to upload our app's code up to Heroku.
    We'll do this with the standard `git push` command
    and copy our local `master` branch to Heroku's `master` branch:

    ```bash
    git push heroku master
    ```

    First,
    the source code will be uploaded to Heroku.
    Heroku will detect the Node.js
    and Crystal components of the app,
    download the appropriate dependencies,
    and compile everything together.
    These steps may take a few minutes to run.
    Finally,
    it will start Lucky
    and run the app!

    > Migrations will happen automatically when the app is pushed to Heroku.
    > Lucky makes it so you never have to worry about forgetting to migrate our app when it's deployed!
    > Read more about the [release phase](https://devcenter.heroku.com/articles/release-phase).

    To see our deployed app,
    use Heroku's `open` command:

    ```bash
    heroku open
    ```

    Happy shipping! 🚀

    ## Running tasks

    To run any of your Lucky tasks on your new Heroku container, use Heroku's `run` command:

    ```bash
    heroku run lucky db.create_required_seeds
    ```

    For a list of the tasks available, run `lucky -h` locally.

    MD
  end
end
