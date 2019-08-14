class Guides::GettingStarted::Concepts < GuideAction
  guide_route "/getting-started/concepts"

  def self.title
    "Philosophy and Concepts"
  end

  def markdown
    <<-MD
    ## The Lucky philosophy

    Lucky was designed to solve a few core problems that teams often see. Lucky strives to:

    * Catch bugs at compile time, rather than finding them in production.
    * Spend less time writing tests, because the compiler catches many errors for you.
    * Minimize guesswork with conventions for the most common types of objects.
    * Help developers break things into discrete pieces so things are easy to share
      and maintain in the future.
    * Minimize boilerplate code so it's easy to focus on what your app does better
      than everyone else.

    We do that by using Crystal's type system to the fullest. You won't see strings
    or symbols passed around. Instead you'll see method calls with types that make
    sure bugs are caught early.

    We have conventions that help you break your app into smaller pieces that are
    easier to understand. Things like single class per action, and form objects.

    We have helpful code generation so that you don't need to repeat boilerplate.

    Lucky was designed for developers that love making reliable products. We think
    you'll love it.

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
