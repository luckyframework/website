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

    If you'd like to skip the wizard, you can run `lucky custom.init my_app`. This option supports
    all of the same options as the wizard does, but also with some additional flags for quick customization.

    This option is great if you need to generate a Lucky app programmatically, or just prefer to get going right away.

    ```
    # Generate a Full Web app with Authentication
    lucky custom.init my_app

    # Generate an API only app
    lucky custom.init my_app --api

    # Skip generating User Auth
    lucky custom.init my_app --no-auth

    # Customize the directory where your app is generated.
    # Default is your current directory
    lucky custom.init my_app --dir /home/me/projects
    ```

    > Use the `-h` flag for a quick reference from the terminal.

    ## Start the Server

    To start the server and run your project,
    * first change into the directory for your newly created app with `cd {project_name}`.
    * Next, you may need to update your database settings in `config/database.cr`.
    * Then run `script/setup` to install dependencies
    * and finally `lucky dev` to start the server.

    Running `lucky dev` will use an installed process manager (Overmind, Foreman,
    etc.) to start the processes defined in `Procfile.dev`. By default
    `Procfile.dev` will start the lucky server, start asset compilation (browser app only),
    and run a [system check](##{ANCHOR_SYSTEM_CHECK}).

    > Lucky will look for a number of process managers. So if you prefer Forego
    and someone else on your team prefers to use Overmind, `lucky dev` will work
    for both of you.

    ## Script Helpers

    Your new Lucky project comes with a few helper scripts located in the `script/` folder.

    ### Setup script

    The first script you will use is the `script/setup`. You should ran this after you
    first create your project. It will do a few things for you.

    * Run a [system check](##{ANCHOR_SYSTEM_CHECK}) script first.
    * Install Javascript dependencies. (browser app only)
    * Install Crystal dependencies.
    * Add a `.env` file if you don't already have one.
    * Create your database. (Note: the configuration settings are in `config/database.cr`)
    * Verify the connection to your database.
    * Run [database migrations](#{Guides::Database::Migrations.path}).
    * Seed your database with data.

    #{permalink(ANCHOR_SYSTEM_CHECK)}
    ### System check script

    The `script/system_check` script is called when you run `script/setup`. It is also called every
    time you run `lucky dev` because Lucky defines a `system_check` process in your `Procfile.dev`.

    The purpose of this script is to check that your system has everything it needs in order to run
    this application for local development. By default we check these things:

    * Ensure `yarn` is installed. (browser apps only)
    * Ensure you have a process manager (Overmind, Foreman, etc.)
    * Check that postgres client tools are installed.

    You can also extend this script to include checks for additional systems you may need.
    (i.e. redis, elasticsearch, etc.).

    ## Bash function helpers

    Located in `script/helpers/function_helpers` is a set of Bash functions used for writing a few
    simple checks for your Lucky app.

    ### The `command_not_found` function

    return `true` if the command passed to it is not found.

    ```bash
    if command_not_found "yarn"; then
      echo "Yarn is not installed"
    fi
    ```

    ### The `command_not_running` function

    return `true` if the command passed to it is not currently running.

    ```bash
    if command_not_running "redis-cli ping"; then
      echo "Redis is not running"
    fi
    ```

    ### The `is_mac` function

    return `true` if you run this script on macOS.

    ```bash
    if is_mac; then
      echo "Running on macOS"
    fi
    ```

    ### The `is_linux` function

    return `true` if you run this script on linux.

    ```bash
    if is_linux; then
      echo "Running on Linux"
    fi
    ```

    > There are a lot of Linux flavors out there. This should catch the most common ones at least.

    ### The `print_error` function

    print your custom error message and exit to allow for stopping your process manager.

    ```bash
    print_error "Redis is not running. Be sure to start it with 'brew services start redis'"
    ```

    ### Full example

    You can use a combination of these functions to remind you of which services you need
    running every time you start your application for local development. For example,
    if your app uses background job processing, and you need redis running for that to work,
    then you could add this to your `script/system_check`.

    ```bash
    if command_not_found "redis-cli"; then
      print_error "Redis is required, and must be installed"
    fi

    if command_not_running "redis-cli ping"; then
      if is_mac; then
        booting_guide = "brew services start redis"
      fi
      if is_linux; then
        booting_guide = "sudo systemctl start redis-server"
      fi

      print_error "Redis is not currently running. Try using " $booting_guide
    fi
    ```
    MD
  end
end
