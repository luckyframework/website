class Guides::Database::DatabaseSetup < GuideAction
  ANCHOR_SEEDING_DATA       = "perma-seeding-data"
  ANCHOR_MULTIPLE_DATABASES = "perma-multiple-databases"
  guide_route "/database/database-setup"

  def self.title
    "Database Setup"
  end

  def markdown : String
    <<-MD
    ## Configure

    Ensure that your system is running a [PostgreSQL](https://www.postgresql.org/docs/current/tutorial-install.html) version of at least 9.4 or later.

    > If you're using the postgres app on macOS, be sure to install [CLI tools](https://postgresapp.com/documentation/cli-tools.html).

    ### Standard Options

    To configure Lucky to connect to your database, open up your `config/database.cr` file.
    You'll find a few standard options within the `AppDatabase` configure block.

    * database
    * hostname
    * username
    * password
    * port

    > You can also set a `DATABASE_URL` environment variable. (e.g. `postgres://root@localhost:5432/my_database`)

    ### Connection Pool

    Lucky also supports connection pool settings:

    * initial_pool_size
    * max_pool_size
    * max_idle_pool_size
    * checkout_timeout
    * retry_attempts
    * retry_delay

    To set the connection pool options, just append a query string to the end of the
    `settings.url` option (e.g. `?initial_pool_size=5&retry_attempts=2`)

    ### Avram Configuration

    Avram requires a `url` option to be set. If you decide to not use Avram as your ORM,
    you can set this option to a string like `"unused"`.

    Optionally, the `lazy_load_enabled` is set to `false` for development and test.
    This causes Lucky to raise an exception if you forget to preload an association,
    but will not raise an exception in production.

    ## Test Setup

    If you'd like to use separate credentials for your testing database, you can add
    another conditional in `config/database.cr` that checks for `Lucky::Env.test?` and
    sets the `setting.url` option to the appropriate value.

    ## Create and Drop database

    ### Create database

    To create your database, run the `lucky db.create` task. This will create the database
    named from `database_name` in your `config/database.cr` file.

    ### Drop database

    To drop the database, run the `lucky db.drop`

    > Please *please* don't ever do this in production

    #{permalink(ANCHOR_SEEDING_DATA)}
    ## Seeding Data

    Seeding is the process of putting data in to your database. This could be fake placeholder
    data you use in development, or even special data your application expects to exist in production.

    By default, Lucky generates two tasks in your app's `tasks/` folder. `Db::CreateRequiredSeeds`,
    and `Db::CreateSampleSeeds`. You can use [Boxes](#{Guides::Database::Testing.path}) or [Operations](#{Guides::Database::ValidatingSaving.path}) to create the data.

    ### Required Seeds

    Let's say you're getting ready to launch your application to production for the very first time.
    You may need an initial Admin user account that will be able to login and create your other Admin accounts.

    This code will go in `tasks/create_required_seeds.cr`.

    ```crystal
    def call
      # Using a Box
      UserBox.create &.email("developer@example.com").admin(true)

      # Using an Operation
      SaveUser.create!(email: "developer@example.com", admin: true)
    end
    ```

    Run this task with `lucky db.create_required_seeds`.

    > This task should be ran after your first deployment, and whenever your seeds change.
    > Running `./script/setup` will run the `db.create_required_seeds` task for you.

    ### Sample Seeds

    This data is a great way to fill your development database with fake placeholder data
    to mimic a fully functioning production database without the worry of losing production data.

    This code will go in `tasks/create_sample_seeds.cr`.

    ```crystal
    def call
      # Using a Box
      100.times do
        ProductBox.create
      end

      # Using an Operation
      100.times do |i|
        SaveProduct.create!(name: "Product \#{i}")
      end
    end
    ```

    Run this task with `lucky db.create_sample_seeds`.

    > Running `./script/setup` in development will run the `db.create_sample_seeds` task for you.
    > If you need to re-seed, you can run `lucky db.drop` and then `./script/setup` to re-create
    > and seed your local database.

    #{permalink(ANCHOR_MULTIPLE_DATABASES)}
    ## Multiple Databases

    Avram supports a multi-database setup which you may need to use for connecting to a legacy
    db, or maybe doing a read/write replica setup.

    By default, Lucky gives you the `AppDatabase` class for your primary DB. To add a second one,
    you'll need to create a new class and inherit from `Avram::Database`.

    ```crystal
    # src/secondary_database.cr
    class SecondaryDatabase < Avram::Database
    end
    ```

    Then require the file in `src/app.cr`:

    ```crystal
    # Add this right above the `require "./app_database.cr"`
    require "./secondary_database.cr"
    ```

    Next, you'll need to add the connection info for the `SecondaryDatabase`.

    ```crystal
    # config/database.cr
    SecondaryDatabase.configure do |settings|
      settings.url = ENV["SECOND_DATABASE_URL"]? || Avram::PostgresURL.build(
        database: "db_two",
        hostname: "localhost",
        username: "postgres",
        password: "postgres"
      )
    end
    ```

    Lastly, any models that need to use this database will need to define a class
    method `def self.database` with the database.

    ```crystal
    # src/models/legacy_user.cr
    class LegacyUser < Avram::Model
      table :users do
      end

      def self.database
        SecondaryDatabase
      end
    end
    ```

    If you have many models that require connection to the `SecondaryDatabase`, you can
    make a `SecondaryBaseModel` class in `src/models/secondary_base_model.cr` and have
    those models inherit from that class.

    ```crystal
    # src/models/secondary_base_model.cr
    abstract class SecondaryBaseModel < Avram::Model
      def self.database : Avram::Database.class
        SecondaryDatabase
      end
    end
    ```

    Require it in `src/app.cr`:

    ```crystal
    # Add this right above the `require "./models/base_model.cr"`
    require "./secondary_base_model.cr"
    ```

    Models can now inherit from this class:

    ```crystal
    class LegacyUser < SecondaryBaseModel
    end
    ```


    > Note: migrations are ran against the `AppDatabase`. If you need to run migrations against
    > another database, you'll need to update the `database_to_migrate` option in `config/database.cr`
    MD
  end
end
