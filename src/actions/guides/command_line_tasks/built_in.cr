class Guides::CommandLineTasks::BuiltIn < GuideAction
  guide_route "/command-line-tasks/built-in"

  def self.title
    "Built In Tasks"
  end

  def markdown
    <<-MD
    ## Overview

    Tasks are used to run some code that sits outside of your main application. When you need to add a task, you'll place it in the `tasks` folder. To see a list of the available tasks in your application, use `lucky --help`.

    You can think of a Luck Task just like a [Rake task](https://github.com/ruby/rake) in Ruby, [npm script](https://docs.npmjs.com/misc/scripts) for Node, or [Mix Task](https://hexdocs.pm/mix/Mix.Task.html) for Elixir.

    To run a task, you just run
    ```
    lucky name.of.task [options]
    ```

    ## Built-in Tasks

    By default, Lucky has a few tasks already built in that you may find really handy while developing your application. These are the ones that you get by default.

    ```
    # Generated with lucky --help
    lucky db.create       - Create the database
    lucky db.drop         - Drop the database
    lucky db.migrate      - Migrate the database
    lucky db.migrate.one  - Run the next pending migration
    lucky db.redo         - Rollback then run the last migration
    lucky db.rollback     - Rollback the last migration
    lucky db.rollback_all - Rollback all migrations
    lucky gen.action      - Generate a new action
    lucky gen.migration   - Generate a new migration
    lucky gen.model       - Generate a model, query, and form
    lucky gen.secret_key  - Generate a new secret key
    lucky routes          - Show all the routes for the app
    lucky watch           - Start and recompile project when files change
    ```
    MD
  end
end
