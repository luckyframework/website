class Guides::Database::DatabaseSetup < GuideAction
  guide_route "/database/database-setup"

  def self.title
    "Database Setup"
  end

  def markdown
    <<-MD
    ## Configure

    Ensure that your system is running a [PostgreSQL](https://www.postgresql.org/docs/current/tutorial-install.html) version of at least 9.4 or later.

    > If you're using the postgres app on macOS, be sure to install [CLI tools](https://postgresapp.com/documentation/cli-tools.html).

    ### Standard Options

    To configure Lucky to connect to your database, you can define a `DATABASE_URL` environment variable. (e.g. `postgres://root@localhost:5432/my_database`). To see more options, look in your app's `config/database.cr` file.
    In this file, you'll find options for configuring

    * database_name
    * hostname
    * username
    * password
    * port

    ### Connection Pool

    Lucky also supports connection pool settings:

    * initial_pool_size
    * max_pool_size
    * max_idle_pool_size
    * checkout_timeout
    * retry_attempts
    * retry_delay

    To set the connection pool options, just append a query string to the end of the `settings.url` option (e.g. `?initial_pool_size=5&retry_attempts=2`)

    ### Avram Configuration

    Avram requires a `url` option to be set. If you decide to not use Avram as your ORM, you can set this option to a string like `"noop"`.

    Optionally, the `lazy_load_enabled` is set to `false` for development and test. This causes Lucky to raise an exception if you forget to preload an association.

    ## Test Setup

    If you'd like to use separate credentials for your testing database, you can add another conditional in `config/database.cr` that checks for `Lucky::Env.test?` and sets the `setting.url` option to the appropriate value.

    ## Create and Drop database

    ### Create database

    To create your database, run the `lucky db.create` task. This will create the database named from `database_name` in your `config/database.cr` file.

    ### Drop database

    To drop the database, run the `lucky db.drop`

    > Please *please* don't ever do this in production

    ## Seeding Data

    Seeding is the process of putting initial data in to your database. This could be fake placeholder data you use in development, or even special data your application expects to exist in production.

    By default, Lucky generates two tasks in your app's `tasks/` folder. `Db::CreateRequiredSeeds`, and `Db::CreateSampleSeeds`. You can use [Boxes]() or [Forms]() to create the data. Then you will place this code in the `call` method of those tasks

    ### Required Seeds

    Let's say you're getting ready to launch your application to production for the very first time. You may need an initial Admin user account that will be able to login and create your other Admin accounts.

    This code will go in `tasks/create_required_seeds.cr`.

    ```crystal
    def call
      # Using a Box
      UserBox.create &.email("developer@example.com").status(User::Status::Admin.value)

      # Using a Form
      UserForm.create!(email: "developer@example.com", status: User::Status::Admin.value)
    end
    ```

    Run this task with `lucky db.create_required_seeds`.

    > This task should be ran after your first deployment of your application.

    ### Sample Seeds

    This data is a great way to fill your development database with fake placeholder data to mimic a fully functioning production database without the worry of losing production data.

    This code will go in `tasks/create_sample_seeds.cr`.

    ```crystal
    def call
      # Using a Box
      100.times do
        ProductBox.create
      end

      # Using a Form
      100.times do |i|
        ProductForm.create(name: "Product \#{i}")
      end
    end
    ```

    Run this task with `lucky db.create_sample_seeds`.

    > Running `./script/setup` in development will run the `db.create_sample_seeds` task for you. If you need to re-seed, you can run `lucky db.drop` and then `./script/setup` to re-create and seed your local database.
    MD
  end
end
