class Guides::CommandLineTasks::CustomTasks < GuideAction
  guide_route "/command-line-tasks/custom-tasks"

  def self.title
    "Custom Tasks"
  end

  def markdown
    <<-MD
    ## Custom Tasks

    Custom tasks you need will be placed in the `tasks` folder of your application. The three main things to creating a custom task is that your class inherits from `LuckyCli::Task`, it implements a `call` method, and includes a `banner`. Be sure to `require "lucky_cli"` at the top of your new task.

    Lucky will infer the name of the task by using the name of your class. This includes using namespaces. (e.g. `Db::Migrate` becomes `lucky db.migrate`).

    ```crystal
    # tasks/generate_sitemaps.cr
    require "lucky_cli"

    class GenerateSitemaps < LuckCli::Task
      banner "Generate the sitemap.xml for this site"

      def call
        # Implement your task here
      end
    end
    ```

    ```
    $ lucky --help

    Usage: lucky name.of.task [options]

    Available tasks:

      ...
      ▸ generate_sitemaps Generate the sitemap.xml for this site
      ...
    ```
    MD
  end
end
