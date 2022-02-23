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
    * Inherit from `LuckyTask::Task`
    * Implement a `call` method
    * Include a `summary`

    ```crystal
    # tasks/generate_sitemaps.cr
    class GenerateSitemaps < LuckyTask::Task
      summary "Generate the sitemap.xml for this site"

      def call
        # Implement your task here
      end
    end
    ```

    Lucky will infer the name of the task by using the name of your class. This includes using namespaces.
    (e.g. `Db::Migrate` becomes `lucky db.migrate`, and `GenerateSitemaps` becomes `lucky generate_sitemaps`).

    Optionally, if you want to customize the name of your task, you can use the `name` macro.

    ```crystal
    class GenerateSitemaps < LuckyTask::Task
      summary "Generate the sitemap.xml for this site"
      name "custom.task"

      def call
        # Implement your task here
      end
    end
    ```

    This will generate a task called `custom.task`

    ## CLI args

    You may need to pass in custom data to your task from the CLI. For this, Lucky gives you three options.

    ### Switch args

    A switch is a simple flag to represent a `Bool`. If you pass the flag, then the value is `true`; otherwise it's `false` by default.

    Use the `switch` macro and pass a symbol for the name of the flag. All flag names are passed with 2 dashes `--` and the name of the symbol. (e.g. `--test-mode`).
    Note that the underscore (`_`) used to define the switch is substituted for a dash (`-`) when using the argument on the comment line.
    In your `call` method, you'll have access to a `test_mode?` method which returns a `Bool`.

    ```crystal
    class ProcessOrders < LuckyTask::Task
      summary "Charge cards, and prep orders for shipping"

      # The second argument is the description of what this flag does.
      switch :test_mode, "Run in test mode. Doesn't charge cards."

      def call
        if test_mode?
          # run test charge
        else
          # run real charge
        end
      end
    end

    # Run this task:
    # lucky process_orders --test-mode
    ```

    You can also specify a "shortcut" flag which is generally a single dash `-` and a single letter. (e.g. `-t`)

    ```crystal
    class ProcessOrders < LuckyTask::Task
      summary "Charge cards, and prep orders for shipping"

      # The second argument is the description of what this flag does.
      switch :test_mode, "Run in test mode. Doesn't charge cards.", shortcut: "-t"

      def call
        if test_mode?
          # run test charge
        else
          # run real charge
        end
      end
    end

    # Run this task:
    # lucky process_orders -t
    ```

    ### Standard args with a value

    These are common flags you will pass to your tasks that require a value to be specified. Similar to the `switch` macro, you will use the
    `arg` macro which gives you a few additional options.

    * `shortcut` - Specify a shorter flag.
    * `optional` - By default, all `arg` specified are required to be passed in. Setting this option to `true` allows you to skip passing this flag.
    * `format` - This is a `Regex` you can use to validate the value of this flag to ensure the data is formatted correctly.

    ```crystal
    class Search::Reindex < LuckyTask::Task
      summary "Reindex search data"

      arg :model, "Only reindex this model",
          shortcut: "-m",
          optional: true,
          format: /^[A-Z]/

      def call
        # The `model` method will equal "User"
        if model
          # reindex only model
        else
          # reindex all models
        end
      end
    end

    # Run this task:
    # lucky search.reindex -m User
    # lucky search.reindex --model=User
    #
    # Running this will throw an error because the value does not match the format:
    # lucky search.reindex -m user
    ```

    ### Int32 and Float64 args

    Similar to the `switch` flags, we use `int32` and `float64` to define inputs that are numerical rather than `Bool` or `String`. Both of these options have a default of
    zero (`0` or `0.0` respectively), which can be overridden with the `default` setting.  When the user omits an `int32` or `float64` input, the default is supplied as the input
    to the task and this helps you gracefully avoid coding for `Nil` values.

    #### Using the `int32` argument

    `int32` macro defines `arg_name` where the return value is an `Int32`.
    If the flag `--arg_name` is passed, the result is the value passed, otherwise is set to
    the specified default, or `0` when not specified.
    Crystal's numeric syntax is supported (i.e. `10_000`) when specifying default values.

      * `arg_name` : String - The name of the argument
      * `description` : String - The help text description for this option
      * `shorcut` : String - An optional short flag (e.g. `-a`)
      * `default` : Int32 - An optional default value (`0` is default when omittted)

    ```crystal
    class QueryOrders < LuckyTask::Task
      summary "Example using int32 parameter."

      # The second argument is the description of what this flag does.
      int32 :limit, "limit (1000, 10_000, etc.)", shortcut: "-l", default: 1_000

      def call
        puts "Limiting number of orders returned to: %0d" % limit
      end
    end

    # Run this task:
    # lucky query_orders --limit=123
    # => "Limiting number of orders returned to: 123"
    #
    # or with the shortcut option:
    # lucky query_orders -l 456
    # => "Limiting number of orders returned to: 456"
    ```

    #### Using the `float64` argument

    `float64` macro defines `arg_name` where the return value is an `Float64`.
    If the flag `--arg_name` is passed, the result is the value passed, otherwise is set to
    the specified default, or `0.0` when not specified.
    Crystal's numeric syntax is supported (i.e. `10_000`) when specifying default values.

      * `arg_name` : String - The name of the argument
      * `description` : String - The help text description for this option
      * `shorcut` : String - An optional short flag (e.g. `-a`)
      * `default` : Float64 - An optional default value (`0.0` is default when omittted)

    ```crystal
    class SmallOrders < LuckyTask::Task
      summary "Example using float64 parameter."

      # The second argument is the description of what this flag does.
      float64 :max_amount, "specifies largest invoice amount", shortcut: "-x", default: 25.0

      def call
        puts "Finding orders up to and including %0.2f" % max_amount
      end
    end

    # Run this task:
    # lucky small_orders --max-amount=25.0
    # => "Finding orders up to and including 25.0"
    #
    # or with the shortcut option:
    # lucky query_orders -x 100
    # => "Finding orders up to and including 100.0"
    ```

    ### Positional args

    These are just syntactical sugar to allow you to pass values without needing to specify a flag. The built-in Lucky tasks use these type of args.

    The `positional_arg` macro has two options:

    * `to_end` - By default, all `positional_arg` passed are of type `String`. If this option is set to `true`, then the value will be of type `Array(String)`.
    * `format` - Just like with `arg`, this is a `Regex` to specify format these values should be in.

    Because positional args don't have flag names, they rely on the position in the CLI to get their value. Their value index corresponds with the order
    in which they are defined with the first one being the first index. If you do not know the number of args that may be passed, you can use the `to_end`
    option to just capture all of the remaining args as an `Array(String)`.

    ```crystal
    class Gen::Model < LuckyTask::Task
      summary "Generate a new model"

      positional_arg :model_name, "The name of the model", format: /^[A-Z]/
      positional_arg :column_types,
                     "The columns for this model in format: col:type",
                     to_end: true,
                     format: /^\\w+:\\w+$/

      def call
        # `model_name` will equal "User"
        run_template_for_model(model_name)

        # `column_types` will equal ["name:string", "email:string", "age:integer"]
        column_types.each do |type|
          # ...
        end
      end
    end

    # Run this task:
    # lucky gen.model User name:string email:string age:integer
    ```

    ## Running Custom Tasks

    Once you've created your custom task, you can run `lucky -h` to see it listed along with all the built-in tasks.

    ```plain
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
    class GenerateSitemaps < LuckyTask::Task
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
