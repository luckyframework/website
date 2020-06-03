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
    * Inherit from `LuckyCli::Task`
    * Implement a `call` method
    * Include a `summary`

    ```crystal
    # tasks/generate_sitemaps.cr
    class GenerateSitemaps < LuckyCli::Task
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

    ### Additional help

    To see a little more information on a specific task, you can use the `-h` or `--help` flag
    on the task.

    ```plain
    $ lucky generate_sitemaps -h
    Generate the sitemap.xml for this site

    Run this task with 'lucky generate_sitemaps'
    ```

    If your task requires special arguments, or needs further explanation, you can override
    this help message by defining a `help_message` method in your task.

    ```crystal
    class GenerateSitemaps < LuckyCli::Task
      summary "Generate the sitemap.xml for this site"
      name "custom.task"

      def help_message
        <<-TEXT
        \#{summary}

        Optionally, you can pass the 'DOMAIN' env to specify which
        domain to generate a sitemap on.

        example: lucky generate_sitemap DOMAIN=company.xyz
        TEXT
      end

      def call
        # Implement your task here
      end
    end
    ```

    Now when we use the `-h` flag on our task, we'll see our full message.

    ```plain
    $ lucky generate_sitemaps -h
    Generate the sitemap.xml for this site

    Optionally, you can pass the 'DOMAIN' env to specify which
    domain to generate a sitemap on.

    example: lucky generate_sitemap DOMAIN=company.xyz
    ```

    > The `lucky -h` task list will continue to only show the `summary`.
    MD
  end
end
