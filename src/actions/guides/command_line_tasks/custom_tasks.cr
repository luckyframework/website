class Guides::CommandLineTasks::CustomTasks < GuideAction
  guide_route "/command-line-tasks/custom-tasks"

  def self.title
    "Custom Tasks"
  end

  def markdown : String
    <<-MD
    ## Creating Custom Tasks

    Place custom tasks in the `tasks` folder of your application.
    Your custom task must:
    1. Inherit from `LuckyCli::Task`
    2. Implement a `call` method
    3. Include a `summary`

    ```crystal
    # tasks/generate_sitemaps.cr
    class GenerateSitemaps < LuckCli::Task
      summary "Generate the sitemap.xml for this site"

      def call
        # Implement your task here
      end
    end
    ```

    Lucky will infer the name of the task by using the name of your class. This includes using namespaces. (e.g. `Db::Migrate` becomes `lucky db.migrate`, and `GenerateSitemaps` becomes `lucky generate_sitemaps`).

    Optionally, if you want to customize the name of your task, you can use the `name` macro.

    ```crystal
    class GenerateSitemaps < LuckyCli::Task
      summary "Generate the sitemap.xml for this site"
      name "custom.task"

      def call
        # Implement your task here
      end
    end
    ```

    This will generate a task called `custom.task`

    ## Running Custom Tasks

    Once you've created your custom task, you can run `lucky -h` to see it listed along with all the built-in tasks.

    ```plaintext
    $ lucky --help

    Usage: lucky name.of.task [options]

    Available tasks:

      ...
      ▸ generate_sitemaps Generate the sitemap.xml for this site
      ...
    ```

    As you can see, your summary will be shown next to the name of the task name. To run this task, just run `lucky generate_sitemaps`

    > Alternatively, if you used the custom name, it would show `custom.task Generate the sitemap.xml for this site`, and you would run it with `lucky custom.task`
    MD
  end
end
