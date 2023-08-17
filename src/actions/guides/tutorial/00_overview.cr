class Guides::Tutorial::Overview < GuideAction
  guide_route "/tutorial/overview"

  def self.title
    "Tutorial Overview"
  end

  def markdown : String
    <<-MD
    ## Our First Lucky Application

    We will be building a "Micro-Blogging" type application. We will call our app *Clover*. This app allows a user to create
    an account, then log in and post "Fortunes" which will be small snippets of text. For example, words of wisdom, pop
    culture references, or good luck wishes!

    A user will be able to view fortunes written by other users.

    This tutorial will cover the following items:

    * Generating a new Lucky application
    * Creating Models and assigning relationships between them
    * Handling database migrations
    * Updating HTML and adding a CSS framework for a bit of design
    * Working with different parts of Lucky
    * Database Queries

    ### Installing

    If you haven't installed Lucky yet, head over to the [Installing Crystal and Lucky](#{Guides::GettingStarted::Installing.path}) guides, first.

    ### Assumptions

    Before we begin, a few assumptions will be made about you, and your skill level. If at any point you feel confused or lost,
    or just need clarification, please [chat with us](#{Chat::Index.path}) so we can clear things up. We love to help!

    We assume you have...

    * some Web Development experience.
    * worked with Crystal, or a similar language (e.g. Ruby, Python, etc...) before, or at least understand the Crystal syntax concepts somewhat. (i.e. classes, modules, instances)
    * worked with some SQL database system before.
    * followed the [Installing guide](#{Guides::GettingStarted::Installing.path}).
    * installed Crystal. `crystal -v` should be at least #{LuckyCliVersion.min_compatible_crystal_version} or higher
    * installed Lucky. `lucky -v` should be #{LuckyCliVersion.current_tag}.
    * installed [Postgres](#{Guides::GettingStarted::Installing.path(anchor: Guides::GettingStarted::Installing::ANCHOR_POSTGRESQL)}). `psql --version` should be `>= #{LuckyDependencyVersions.min_compatible_postgres_version}`
    * installed [Node](#{Guides::GettingStarted::Installing.path(anchor: Guides::GettingStarted::Installing::ANCHOR_NODE)}). `node -v` should be `>= v#{LuckyDependencyVersions.min_compatible_node_version}` (used for building css and javascript)

    ## The Wizard

    From your terminal, we will start the Lucky wizard to generate our application. Run the `lucky init` command:

    ```bash
    lucky init
    ```

    This will ask us what "Project name" we would like to use. We will call it "clover" in all lowercase. Enter `clover`:

    ```
    Project name?: clover
    ```

    Next, the wizard will ask us which format of application we would like to build. We are building a "full" app
    which will allow us to use CSS, JavaScript, and have HTML views. Enter `full`:

    ```
    API only or full support for HTML and Webpack? (api/full): full
    ```

    Lastly, the wizard would like to know if we want to generate authentication. We do! This will give us the ability
    to create user accounts and login/out of our accounts. Enter `y`:

    ```
    Generate authentication? (y/n): y
    ```

    Once that's done, Lucky will give you a few instructions on what to do next. We will follow those instructions
    in the next step.

    > For more information on the wizard, read the [Starting a Lucky Project](#{Guides::GettingStarted::StartingProject.path}) guide.

    ## Booting Our Application

    Before we boot our application, we still need to complete the setup process. This portion is specific to the
    individual as only you will know your own database settings.

    Let's start by changing the directory into the project. Enter `cd clover`

    ```bash
    cd clover
    ```

    Now we need to make sure we can connect to Postgres so we can run SQL. Open up your Clover app project, and
    open the `config/database.cr` file.

    The default postgres connection uses the username `postgres`, and the password `postgres` along with the hostname `localhost`.
    Look over these settings, and update them to match your own personal setup.

    Done? Did you remember to save the file? 😄

    > For more information on setting up your database, read the [Database Setup](#{Guides::Database::DatabaseSetup.path}) guide.

    ### Setup Script

    Next we will run our setup script. This script does a few things:

    * Run a system check for 3rd party dependencies needed to run this app.
    * Setup our assets (css, javascript) using Yarn
    * Install Crystal shard dependencies. (e.g. Lucky, Avram, etc...)
    * Create our database. In this case, a database named `clover_developement`
    * Verify that we can connect to this new database
    * Run SQL code (migration) to create our users table.
    * Import sample data in to our database. On the first run, there's no sample data.

    Run the setup script. Enter `./script/setup`:

    ```bash
    ./script/setup
    ```

    > This may take a bit of time to run. If anything fails at any point, let us know!

    ### Congratulations!

    If you see the output `Run 'lucky dev' to start the app`, then
    you've officially started your first Lucky project! Now you can run the app, and play with it.

    Start the Lucky app. Enter `lucky dev`:

    ```bash
    lucky dev
    ```

    Use `ctrl-c` at any time to stop the server.

    > There are two separate processes that boot; `assets` and `web`. We must wait for both to finish.

    ## Browsing your Application

    Open up your favorite browser, and head over to `http://127.0.0.1:3000`. This URL will be printed
    in your terminal log output.

    > To change the port your app runs on, update the `port` option in the `config/watch.yml` file.

    You should now see the Lucky home page.

    Click the "VIEW YOUR NEW APP" button to be taken to a "Sign Up" page. Because the wizard set us up
    with Authentication, we now have the ability to create a User account, and log in. Make your account!

    After you've signed up, you are taken to your "Profile" page.

    > For more information on the application file structure, read the [Philosophy and Concepts](#{Guides::GettingStarted::Concepts.path}) guide.

    ## Your Turn

    Now that you've generated a real working Lucky app, play around with it! In the next steps,
    we will start building out more of the application.

    Try this:

    * Sign out of your account
    * Sign back in to your account
    * View your terminal to see how each request is logged to the output

    > When you're done, stop your server with `ctrl-C` before moving on to the next section.

    MD
  end
end
