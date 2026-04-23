class Guides::GettingStarted::StartingProject < GuideAction
  ANCHOR_SYSTEM_CHECK = "perma-system-check"
  guide_route "/getting-started/starting-project"

  def self.title
    "Starting a Lucky Project"
  end

  def markdown : String
    <<-MD
    ## Create a New Project

    To create a new project, run `lucky init`.

    The wizard will walk you through naming your application,
    as well as giving you a few options to best customize your setup like authentication.

    Lucky can generate different types of projects based on your needs such as Full or API based.

    ### Full
    * Great for server rendered HTML or Single Page Applications (SPA)
    * Webpack included
    * Setup to compile CSS and JavaScript
    * Support for rendering HTML

    ### API
    * Specialized for use with just APIs
    * No webpack
    * No static file serving or public folder
    * No HTML rendering folders

    ## Skipping the Wizard

    If you'd like to skip the wizard, you can run `lucky init.custom my_app`. This option supports
    all of the same options as the wizard does, but also with some additional flags for quick customization.

    This option is great if you need to generate a Lucky app programmatically, or just prefer to get going right away.

    ```bash
    # Generate a Full Web app with Authentication
    lucky init.custom my_app

    # Generate an API only app
    lucky init.custom my_app --api

    # Skip generating User Auth
    lucky init.custom my_app --no-auth

    # Customize the directory where your app is generated.
    # Default is your current directory
    lucky init.custom my_app --dir /home/me/projects

    # Generate your application with security specs from BrightSec
    lucky init.custom my_app --with-sec-test
    ```

    > Use the `-h` flag for a quick reference from the terminal.

    ## Start the Server

    To start the server and run your project,
    * first change into the directory for your newly created app with `cd {project_name}`.
    * Next, you may need to update your database settings in `config/database.cr`.
    * Then run `crystal script/setup.cr` to install dependencies
    * and finally `lucky dev` to start the server.

    Running `lucky dev` will use an built-in process manager [Nox](https://github.com/crystal-loot/nox)
    to start the processes defined in `Procfile.dev`. By default
    `Procfile.dev` will start the lucky server, start asset compilation (browser app only),
    and run a [system check](##{ANCHOR_SYSTEM_CHECK}).

    ## Script Helpers

    Your new Lucky project comes with a few helper scripts located in the `script/` folder.

    ### Setup script

    The first script you will use is the `script/setup.cr`. You should run this after you
    first create your project. It will do a few things for you.

    * Run a [system check](##{ANCHOR_SYSTEM_CHECK}) script first.
    * Install Crystal dependencies.
    * Install Javascript dependencies. (browser app only)
    * Add a `.env` file if you don't already have one.
    * Create your database. (Note: the configuration settings are in `config/database.cr`)
    * Verify the connection to your database.
    * Run [database migrations](#{Guides::Database::Migrations.path}).
    * Seed your database with data.

    #{permalink(ANCHOR_SYSTEM_CHECK)}
    ### System check script

    The `script/system_check.cr` script is called when you run `crystal script/setup.cr`. It is also called every
    time you run `lucky dev` because Lucky defines a `system_check` process in your `Procfile.dev`.

    The purpose of this script is to check that your system has everything it needs in order to run
    this application for local development. By default we check these things:

    * Ensure `bun` is installed. (browser apps only)
    * Check that postgres client tools are installed.

    You can also extend this script to include checks for additional systems you may need.
    (i.e. redis, elasticsearch, etc.).

    ## Function helpers

    Located in `script/helpers/function_helpers.cr` is a set of functions used for writing a few
    simple checks for your Lucky app. These are just helper methods you can use to streamline your
    setup. These are not required by Lucky, so you are free to alter these as you need.
    MD
  end
end
