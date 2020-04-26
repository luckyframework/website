class Guides::CommandLineTasks::BuiltIn < GuideAction
  guide_route "/command-line-tasks/built-in"

  def self.title
    "Built In Tasks"
  end

  def markdown : String
    <<-MD
    ## Overview

    Tasks are used to run some code that sits outside of your main application. When you need to add a task, you'll place it in the `tasks` folder. To see a list of the available tasks in your application, use `lucky --help`.

    You can think of a Luck Task just like a [Rake task](https://github.com/ruby/rake) in Ruby, [npm script](https://docs.npmjs.com/misc/scripts) for Node, or [Mix Task](https://hexdocs.pm/mix/Mix.Task.html) for Elixir.

    To run a task, you just run
    ```plaintext
    lucky name.of.task [options]
    ```

    ## Built-in Tasks

    By default, Lucky has a few tasks already built in that you may find really handy while developing your application. These are the ones that you get by default.

    ```plaintext
    # Generated with lucky --help
    ▸ build.release             Compile app for production
    ▸ db.create                 Create the database
    ▸ db.create_required_seeds  Add database records required for the app to work
    ▸ db.create_sample_seeds    Add sample database records helpful for development
    ▸ db.drop                   Drop the database
    ▸ db.migrate                Run any pending migrations
    ▸ db.migrate.one            Run just the next pending migration
    ▸ db.migrations.status      Print the current status of migrations
    ▸ db.redo                   Rollback and run just the last migration
    ▸ db.rollback               Rollback the last migration
    ▸ db.rollback_all           Rollback all migrations
    ▸ db.rollback_to            Rollback to a specific migration
    ▸ db.schema.dump            Export database schema to a sql file
    ▸ db.schema.restore         Restore database from a sql dump file
    ▸ db.verify_connection      Verify connection to postgres
    ▸ exec                      Execute code. Use this in place of a console/REPL
    ▸ gen.action.api            Generate a new api action
    ▸ gen.action.browser        Generate a new browser action
    ▸ gen.component             Generate a new HTML component
    ▸ gen.migration             Generate a new migration
    ▸ gen.model                 Generate a model, query, and save operation
    ▸ gen.page                  Generate a new HTML page
    ▸ gen.resource.browser      Generate a resource (model, operation, query, actions, and pages)
    ▸ gen.secret_key            Generate a new secret key
    ▸ routes                    Show all the routes for the app
    ▸ watch                     Start and recompile project when files change
    ```

    > For more information on any of these tasks, you can pass the `-h` or `--help` flag
    > to the task directly. (e.g. `lucky db.migrate --help`)
    MD
  end
end
