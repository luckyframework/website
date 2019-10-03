class Guides::GettingStarted::Concepts < GuideAction
  guide_route "/getting-started/concepts"

  def self.title
    "Philosophy and Concepts"
  end

  def markdown : String
    <<-MD
    ## The Lucky philosophy

    Lucky was designed to solve a few core problems that teams often see. Lucky strives to:

    * **Catch bugs at compile time**, rather than finding them in production.
    * **Spend less time writing tests**, because the compiler catches many errors for you.
    * Minimize guesswork with **conventions for common tasks**.
    * Help developers break things into discrete pieces so things are **easy to share
      and maintain as the codebase grows**.
    * **Minimize boilerplate** code so it's easy to focus on what your app does better
      than everyone else.

    Lucky was designed for developers that love making reliable products. We think
    you'll love it.

    ## How requests are processed

    <div class="shadow rounded bg-white px-6 my-8">
      <img alt="Diagram of how Lucky handles requests" src="#{Lucky::AssetHelpers.asset("images/request-overview-diagram.png")}">
    </div>

    1. Browser or client makes an HTTP request.
    2. Lucky routes the request to a matching [Action](#{Guides::HttpAndRouting::RoutingAndParams.path}).
      * In Lucky, [an Action defines what HTTP method and path it handles](#{Guides::HttpAndRouting::RoutingAndParams.path}).
    3. Action processes the request. For example:
      * [Query the database with Avram](#{Guides::Database::QueryingDeleting.path}).
      * [Create or update db records with Avram](#{Guides::Database::ValidatingSaving.path}).
      * [Send an email with Carbon](#{Guides::Emails::SendingEmailsWithCarbon.path}).
    4. The Action generates a response for the browser or client. For example:
      * [Generate an HTML page](#{Guides::Frontend::RenderingHtml.path}).
      * [Redirect to another URL or Action](#{Guides::HttpAndRouting::RequestAndResponse.path(anchor: Guides::HttpAndRouting::RequestAndResponse::ANCHOR_REDIRECTING)}).
      * [Send JSON](#{Guides::JsonAndApis::RenderingJson.path}).
    5. The response is delivered to the browser or client.

    ## File structure overview

    A new Lucky app is a slightly modified version of a Crystal app.

    ### `src` folder

    The src folder holds most of your application code. This includes actions for handling requests,
    queries for database access, pages for rendering HTML, and a few other things.

    ### `config` folder

    Here are all the files for configuring your application. A new app comes with a
    few configuration files, but you can add more as you see fit.

    ### `db` folder

    This folder houses all the database migrations for your app.

    ### `tasks` folder

    You can put custom tasks here that can be run by the `lucky` command line tool. See `lucky -h` for a list of the current tasks.

    ### `public` folder

    Place any files you wish to be public in here. For compiled assets, the asset compiler will move the files in to here for you.

    ### `script` folder

    This folder contains a setup script for bootstrapping your app by default. Place any other bash style scripts or executables you may need for your app in here.

    ### `spec` folder

    The test files for your application will go in to this folder.

    ### `Procfile` and `Procfile.dev`

    `Procfile.dev` is used when you run `lucky dev`. By default there is a web and an assets process
    that are started. You can add more if you need them.

    `Procfile` is often used in production. Companies like Heroku, use it to determine
    how it should run the app.

    ## The `src` folder

    It's standard convention for Crystal applications to place the main business logic in to this folder, so there's a lot that is going on here.

    ### `actions` folder

    This is where classes go that handle incoming web requests.

    ### `actions/mixins` folder

    Action mixins are modules that you can include in actions. Great for authentication, authorization, setting up finders or ensuring certain headers are set.

    ### `components` folder

    These are shared view components like displaying flash messages, errors, and default layout components like the head tags.

    ### `css` folder

    Place your styles in here. By default, Lucky uses [SASS](https://sass-lang.com/), but you can configure for any preprocessor.

    ### `emails` folder

    The classes used by [Carbon](#{Guides::Emails::SendingEmailsWithCarbon.path}) along with the email templates are placed in here.

    ### `operations` folder

    Operations for saving database records or interacting with HTTP forms.

    ### `js` folder

    Your javascript files will go in here.

    ### `models` folder

    Put anything that models your business. Database objects go here, but you could
    also put things like service objects.

    ### `pages` folder

    Pages used for rendering HTML in response to web requests.

    ### `queries` folder

    This is where your database queries go.

    ### `serializers` folder

    This is more common with APIs. These are the files that transform your structured data in to some format like json or xml.

    ### `app.cr`

    This requires all the files and folders that your app needs to run.

    ### `app_server.cr`

    This includes your middleware stack. Add your custom HTTP::Handlers to the `middleware` method array.

    ### `shards.cr`

    Require your third party dependencies (shards) here.

    ### `start_server.cr`

    This file requires the app and starts an HTTP server.

    ## Adding custom files and folders

    The structure in Lucky is to create a folder for like objects/modules, etc... You may find yourself adding things like service objects, custom http handlers, mutations, or maybe even other asset files like images for preprocessing. For each of these, just create a new folder in `src/` and be sure to add the require in your `src/app.cr`.

    e.g. Creating a `src/handlers/http_basic_auth_handler.cr`, be sure to add `require "./handlers/**"` to `src/app.cr`.
    MD
  end
end
