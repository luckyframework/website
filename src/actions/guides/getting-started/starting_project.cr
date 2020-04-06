class Guides::GettingStarted::StartingProject < GuideAction
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
    * Then run `script/setup` to install dependencies
    * and then `lucky dev` to start the server.

    Running `lucky dev` will use an installed process manager (Overmind, Foreman,
    etc.) to start the processes defined in `Procfile.dev`. By default
    `Procfile.dev` will start the lucky server, and will start asset compilation not in API mode.

    > Lucky will look for a number of process managers. So if you prefer Forego
    and someone else on your team prefers to use Overmind, `lucky dev` will work
    for both of you.
    MD
  end
end
