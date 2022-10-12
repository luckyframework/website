class Guides::Database::Migrations < GuideAction
  ANCHOR_ASSOCIATIONS            = "perma-associations"
  ANCHOR_PRIMARY_KEYS            = "perma-primary-keys"
  ANCHOR_ADVANCED_COLUMN_OPTIONS = "perma-advanced-column-options"
  guide_route "/database/migrations"

  def self.title
    "Migrations"
  end

  def markdown : String
    <<-MD
    ## Migrating Data

    ### Introduction to migrations

    You can think of migrations like version control for your database.
    These are classes that are scoped with a timestamp to allow you to update your database
    in versions as well as undo changes that you've made previously.

    Your migration files will live in the `db/migrations/` folder of your Lucky application.

    ### Anatomy

    A new migration file name will always start with a timestamp. This is to keep the order
    in which they are ran. You may have a migration that adds a column, and then a year later,
    another one that removes that column. You want to run these in the correct order.

    In that file, you'll find two methods `migrate`, and `rollback`.

    * migrate - This method runs your new SQL when moving forward (migrating).
    * rollback - This method should undo everything the `migrate` method does.

    > The `rollback` method should do the opposite of `migrate` in reverse order.
    > (e.g. If `migrate` adds a column, then adds an index for that column, `rollback` should
    > remove the index first, then remove the column.)

    ### Generating a new migration

    To create a new migration, run the `lucky gen.migration {PurposeOfMigration}` command line task.
    (e.g. If you need to add a `name` column to `users`, you would run `lucky gen.migration AddNameToUsers`).
    This would generate a `db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_name_to_users.cr` file.

    > There is a task for generating a new model `lucky gen.model`. When you
    generate a new model, a migration file is created for you.

    ### Other CLI DB Tasks

    Lucky comes with several tasks you can run for handling your migrations.

    * `db.migrate` - Run all pending migrations.
    * `db.migrate.one` - Run only the next pending migration.
    * `db.redo` - Rollback to the previous migration, then re-run the last migration again.
    * `db.rollback` - Undo the last migration ran.
    * `db.rollback_to MIGRATION_TIMESTAMP` - Undo all migrations back to `MIGRATION_TIMESTAMP`
    * `db.rollback_all` - Undo all of the migrations back to the beginning.
    * `db.migrations.status` - Displays the current status of migrations.
    * `db.verify_connection` - Tests that Avram can connect to your database.
    * `db.setup` - Create then migrate your database.

    [Learn more about tasks](#{Guides::CommandLineTasks::BuiltIn.path})

    ## Tables

    Most migrations will use `table_for` to generate a table
    name from the passed in class. The generated table name will be the
    pluralized and underscored name of the class.

    For example:

    ```crystal
    # table_for will return :completed_projects
    table_for(CompletedProject)
    ```

    The table name generated by `table_for` will match the model when the
    model uses the default table name (no arg passed to `table`). This ensures
    your table names will match up.

    ```crystal
    # src/models/completed_project.cr
    class CompletedProject < Avram::Model
      # By default uses the pluralized and underscored class name.
      table do
        # Define columns
      end
    end
    ```

    ### Creating a table

    Use the `create` method for creating a table. You will place all of the table definitions
    inside of the `create` block.

    ```crystal
    def migrate
      create table_for(User) do
        # Add column definitions here. Shown later in the guide
      end
    end
    ```

    Use this in conjunction with the `table` macro for your models. See [setting up a model](#{Guides::Database::Models.path})
    for more information.

    > You can also use a symbol for a table name. For example `create :users`.

    ### Altering a table

    If your table exists, and you need to make changes to *this* table, use the `alter` method.
    All of your changes will go in the `alter` block.

    ```crystal
    def migrate
      alter table_for(User) do
        # Add column definitions here. Shown later in the guide
      end
    end
    ```

    > You can also use a symbol for a table name. For example `alter :users`.

    ### Dropping a table

    To drop a table, use the `drop` method.

    ```crystal
    def migrate
      drop table_for(User)
    end
    ```

    Remember, if your `migrate` method runs `create`, then the `rollback`
    method should run `drop`.

    > You can also use a symbol for a table name. For example `drop :users`.

    ## Columns

    There are a few different datatypes that you can use to declare the column type.

    * `String` - Maps to postgres `text`.
    * `Int16` - Maps to postgres `smallint`.
    * `Int32` - Maps to postgres `int`.
    * `Int64` - Maps to postgres `bigint`.
    * `Time` - Maps to postgres `timestamptz`.
    * `Bool` - Maps to postgres `boolean`.
    * `Float64` - Maps to postgres `decimal`. With options for precision and scale.
    * `UUID` - Maps to postgres `uuid`.
    * `Bytes` - Maps to postgres `bytea`.
    * `JSON::Any` - Maps to postgres `jsonb`.
    * `Array(T)` - Maps to postgres array fields where `T` is any of the other datatypes.

    ### Adding a column

    To add a new column, you'll use the `add` macro inside of a `create` block
    or `alter` block. The first argument will be a type declaration followed by
    any options that column may need. (i.e. default value, index, etc...)

    ```crystal
    create table_for(User) do
      add email : String
      add birthdate : Time
      add login_count : Int32, default: 0
      add tags : Array(String)
      add preferences : JSON::Any
    end
    ```

    ```crystal
    alter table_for(User) do
      add last_known_ip : String?
    end
    ```

    ### Making columns required or optional

    By default columns are **required** (`NOT NULL` in SQL terms). You can
    allow nulls by adding a `?` to the type.

    For example, this is required:

    ```
    add name : String
    ```

    But adding `?` will tell Avram to make this column optional (allow `NULL`):

    ```
    add name : String?
    ```

    If you have a column that currently allows NULL values, you can use the `make_required`
    method in a later migration to set that column NOT NULL.

    ```crystal
    def migrate
      # turns `String?` in to `String`
      make_required table_for(User), :name
    end
    ```

    Or make the column optional if it's already required:

    ```crystal
    def migrate
      # turns `String` in to `String?`
      make_optional table_for(User), :name
    end
    ```

    > More example usages of these are below

    ### Renaming a column

    The `rename` method must go in the `alter` block.

    ```crystal
    alter table_for(User) do
      rename :old_name, :new_name
      rename :birthday, :birthdate
    end
    ```

    ### Changing column type

    To change your column type, you'll use the `change_type` macro. This is very useful for
    when you need to change a column from one type to another. One example may be updating your
    primary key from `Int32` to `Int64`.

    ```crystal
    alter table_for(User) do
      # update your `id` column from postgres `serial` to `bigserial`
      change_type id : Int64
    end
    ```

    You can also update some of the options passed to a column such as a float precision.

    ```crystal
    alter table_for(Transaction) do
      change_type amount : Float64, precision: 4, scale: 2
    end
    ```

    ### Removing a column

    The `remove` method must go in the `alter` block.

    ```crystal
    alter table_for(User) do
      remove :middle_name
      remove :last_login_ip
    end
    ```

    #{permalink(ANCHOR_ADVANCED_COLUMN_OPTIONS)}
    ### Column options

    The `add` macro takes several options for further customization when adding a field.

    * `index` - `false` by default. When `true`, this will create an index on this column.
    * `using` - `:btree` by default. The index method to use when an index is created.
    * `unique` - `false` by default. When `true`, postgres will enforce a unique constraint on this field.
    * `default` - The default value to use for this column.
    * `case_sensitive` - Make the `String` column use the `citext` extention.

    ```crystal
    create table_for(User) do
      add email : String, index: true, unique: true
      add login_count : Int32, default: 0
    end
    ```

    Avram supports the postgres [citext](https://www.postgresql.org/docs/12/citext.html)
    column type. To use this, you'll need to enable the `citext` extension first.
    Then specify the column as a `String` type, and use the option `case_sensitive: false`.

    By default, all strings in postgres are case sensitive. This means that saving the email
    "Joy@Happy.Co" and looking for "joy@happy.co" will not return any values. The citext extention
    allows this column to be case insensitive.

    ```crystal
    def migrate
      # Be sure to add this line!
      enable_extension "citext"

      create table_for(User) do
        add email : String, case_sensitive: false
      end
    end
    ```

    ### Column helpers

    To generate the default `created_at` and `updated_at` timestamps,
    you can use the `add_timestamps` helper method.

    ```crystal
    create table_for(User) do
      # adds `created_at : Time`, and `updated_at : Time` columns
      add_timestamps
    end
    ```

    #{permalink(ANCHOR_PRIMARY_KEYS)}
    ## Primary and Foreign Keys

    You will need to specify your primary key in your `create` block using the `primary_key` method.
    Avram currently supports these key types:

    * `Int16` - maps to postgres `smallserial`.
    * `Int32` - maps to postgres `serial`.
    * `Int64` - maps to postgres `bigserial`.
    * `UUID` - maps to postgres `uuid`. Generates V4 UUID (requires the "pgcrypto" extension)

    To specify your primary key, you'll use the `primary_key` method.

    ```crystal
    def migrate
      create table_for(User) do
        # creates a primary key column named `id`
        primary_key id : Int64
      end
    end
    ```

    Or for UUID

    ```crystal
    def migrate
      enable_extension "pgcrypto"

      create table_for(User) do
        primary_key id : UUID
      end
    end
    ```

    > Avram expects the primary key name to be `id`, but Avram supports using
    any primary key column name. (e.g. `primary_key custom_name : Int64`)

    ## Using fill_existing_with and default values

    When using the `add` macro inside an `alter` block, there's an additional option `fill_existing_with`.

    * `fill_existing_with` will backfill existing records with this value; however,
      new records will not have any values by default.
    * `default` will set the column's default value, and postgres will automatically backfill
      existing records with this default.

    Since these options solve similar problems, they can't both be used at the same time.

    ```crystal
    alter table_for(User) do
      # set all existing, and future users `active` to `true`
      add active : Bool, default: true

      # set all existing users `otp_code` to `"fake-otp-code-123".
      # New users will require a value to be set.
      add otp_code : String, fill_existing_with: "fake-otp-code-123"
    end
    ```

    > You can also use `fill_existing_with: :nothing` if your table is empty.

    If a static value will not work, try this:

    * If you have not yet released the app, consider using `fill_existing_with: :nothing`
      and resetting the database with `lucky db.reset`.
    * Consider making the type nilable (example: `add otp_code : String?`), then fill the values with whatever
      value you need. Then make it required with `make_required :users, :otp_code`. See the example below:

    ### Filling a newly generated column with custom data

    This will require 2 separate migrations. The first migration will run and create the
    new column as a "NULLABLE" column. The second migration will set the value on that
    column, then ensure the column is not NULLABLE.

    * Run `lucky gen.migration AddOtpCodeToUsers`

    ``` crystal
    # db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_otp_code_to_users.cr
    def migrate
      alter table_for(User) do
        # Add nullable column first
        add otp_code : String?
      end
    end

    def rollback
      alter table_for(User) do
        remove :otp_code
      end
    end
    ```

    * Run `lucky gen.migration FillOtpCodeAndMakeRequired`

    For this migration, we will create a custom model that is used
    to both query, and update the table. This pattern allows us to
    keep this migration "future-proof" from potential model changes.

    ```crystal
    # db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_fill_otp_code_and_make_required.cr
    class FillOtpCodeAndMakeRequired::V#{Time.utc.to_s("%Y%m%d%H%I%S")} < Avram::Migrator::Migration::V1
      class TempOTPUser < Avram::Model
        skip_default_columns
        skip_schema_enforcer

        def self.database : Avram::Database.class
          AppDatabase
        end

        table :users do
          primary_key id : UUID # or whatever your PKEY type is...
          column otp_code : String?
        end
      end

      def migrate
        TempOTPUser::BaseQuery.new.each do |user|
          TempOTPUser::SaveOperation.update!(user, otp_code: Random::Secure.urlsafe_base64)
        end

        make_required table_for(User), :otp_code
      end

      def rollback
        make_optional table_for(User), :otp_code
      end
    end
    ```

    ## Using an Index

    Indexes are used in the database to make lookup on a specific column, or group of columns
    faster.

    ### Adding an index

    The easiest way is to add the `index: true` option on the `add` macro.
    However, if you're adding indices after the table is created, or a multi-column index,
    you can use the `create_index` method.

    ```crystal
    def migrate
      create_index table_for(User), [:status], unique: false
    end
    ```

    The name of the index will be generated for you automatically. If you would like to use your own
    custom index name, you can pass the `name` option.

    ```crystal
    def migrate
      create_index :users,
                   [:status, :joined_at, :email],
                   name: "special_status_index"
    end
    ```

    > Postgres imposes a 63 byte limit on identifiers. If you create an index on a lot of columns,
    > you will want to create a custom index name to avoid it being truncated.
    > [read more](https://til.hashrocket.com/posts/8f87c65a0a-postgresqls-max-identifier-length-is-63-bytes)


    ### Dropping an index

    Use the `drop_index` method to remove the index from the table.

    ```crystal
    def migrate
      drop_index table_for(User), [:status]
    end
    ```

    ## Views

    A SQL VIEW is simlar to a table, except read-only, and doesn't normally include any sort of primary key.
    These are great for pulling data from a larger table in to a smaller set for quicker access, or if you need
    to combine data from multiple tables.

    It will be up to you to decide where the data will come from.

    ### Creating a view

    Currently there are no built-in helpers for managing views. You will use the `execute` method
    with your VIEW SQL.

    ```crystal
    def migrate
      execute <<-SQL
      CREATE VIEW admin_users AS
        SELECT users.*
        FROM users
        JOIN admins on admins.name = users.name;
      SQL
    end
    ```

    Use this in conjunction with the `view` macro for your models. See [setting up a model](#{Guides::Database::Models.path})
    for more information.

    ### Updating a view

    To update a VIEW, you use the `execute` method and redefine the view with `CREATE OR REPLACE`.

    ```crystal
    def migrate
      execute <<-SQL
      CREATE OR REPLACE VIEW admin_users AS
        SELECT users.*
        FROM users
        JOIN admins ON admins.key = users.key
        WHERE users.active = 't';
      SQL
    end
    ```

    ### Dropping a view

    To drop a view, use `execute` with a `DROP VIEW` SQL call.

    ```crystal
    def rollback
      execute "DROP VIEW admin_users;"
    end
    ```

    ### Materialized views

    These are another type of view, but with some small differences. A VIEW works by using
    the query you defined, and essentially running that query at the time you call the view
    to return the data. In much larger datasets, this can start to slow down.

    A Materialzed view will run the query once, and store the data that's fetched in to a
    special table. Looking up data from this special table will always be the same until you
    have told the view to refresh the data. This can increase performance.

    Currently Lucky does not have any built-in methods, but you can use the `execute` method
    with raw SQL.

    It is up to you to define how the data should be fetched.

    ```crystal
    def migrate
      execute <<-SQL
      CREATE MATERIALIZED VIEW IF NOT EXISTS campaign_stats AS
        WITH data AS (
          ...
        )
        SELECT campaign_id, amount
        FROM data
      SQL
    end
    ```

    Your model will need to be setup slightly different from a standard view model.

    ```crystal
    class CampaignStat < BaseModel
      # The SchemaEnforcer must be ignored for materialzed views
      skip_schema_enforcer

      view do
        column campaign_id : UUID
        column amount : Int64
      end

      # Use this to refresh your view periodically
      def self.refresh_view(*, concurrent : Bool = false)
        database.exec("REFRESH MATERIALIZED VIEW \#{concurrent ? "CONCURRENTLY" : ""} \#{table_name}")
      end
    end
    ```

    #{permalink(ANCHOR_ASSOCIATIONS)}
    ## Associations

    If your tables have a one-to-many or a many-to-many relation, you can use these
    methods to create a foreign key constraint, or remove that constraint from your tables.

    [Learn more about associations with models](#{Guides::Database::Models.path(anchor: Guides::Database::Models::ANCHOR_MODEL_ASSOCIATIONS)})

    ### Add belongs_to

    The `add_belongs_to` method will create that foreign key constraint.

    For example, we can tell our database that a `Comment` should reference a `User` as its author:

    ```crystal
    def migrate
      create table_for(Comment) do
        # This will create an author_id column with an index and a foreign_key
        # set to the users table.
        #
        # When the associated author is deleted, their comments are also deleted
        # because we set on_delete: :cascade
        add_belongs_to author : User, on_delete: :cascade
      end
    end
    ```

    This will generate a column called `author_id` on the `comments` table with a foreign key constraint pointing to an entry in the `users` table. It will also ensure that when a `User` is removed from the database, all associated `Comments` are also removed:

    ```
    comments_author_id_fkey" FOREIGN KEY (author_id)
        REFERENCES users(id) ON DELETE CASCADE
    ```

    You must include the `on_delete` option which can be one of
    * `:cascade` - if the parent (i.e. `User`) is deleted, then also delete the associated records in this table (i.e. `comments`)
    * `:restrict` - if the parent is deleted, and there are associated records, then restrict the parent (i.e. `User`) from being deleted.
    * `:nullify` - if the parent is deleted, it should nullify the foreign key for all associated records. This should only be used if the `belongs_to` is optional.
    * `:do_nothing` - just do nothing.

    If the foreign key is `UUID`, you will need to specify the `foreign_key_type` option
    so the proper type is added.

    ```crystal
    def migrate
      create table_for(Comment) do
        primary_key id : UUID
        add_timestamps
        add_belongs_to author : User, on_delete: :cascade, foreign_key_type: UUID
      end
    end
    ```

    ### Rename belongs_to

    When you need to rename the association, you can use `rename_belongs_to`.

    ```crystal
    alter table_for(Employee) do
      # rename `boss_id` to `manager_id`
      rename_belongs_to :boss, :manager
    end
    ```

    ### Remove belongs_to

    When you need to remove the association, you can use `remove_belongs_to`.

    ```crystal
    def migrate
      alter table_for(Comment) do
        # This will drop the author_id column
        remove_belongs_to :author
      end
    end
    ```

    ## Postgres Extensions, Functions, and Triggers

    ### Extensions

    Postgres extensions allow you to enhance your database setup with new functionality. Some common extensions
    are adding [UUID functions](https://www.postgresql.org/docs/current/pgcrypto.html), or using
    [postgis](https://postgis.net/) to do geographic queries. Avram includes a few methods for enabling and disabling
    these extensions.

    ### Enable extension

    ```crystal
    def migrate
      enable_extension "pgcrypto"
    end
    ```

    ### Disable extension

    ```crystal
    def rollback
      disable_extension "pgcrypto"
    end
    ```

    ### Update extension

    ```crystal
    def migrate
      # Update to the latest version of the extension
      update_extension "hstore"

      # or update to a specific version
      update_extension "hstore", to: "2.0"
    end
    ```

    ### Functions

    Postgres functions are like methods you write in SQL that can calculate values for you.
    These functions can be run in a query, or called based on a trigger like updating a record.

    ### Create a function

    Adds the new function to your database.

    ```crystal
    def migrate
      # simple trigger function
      create_function "set_updated_at", <<-SQL
        IF NEW.updated_at IS NULL OR NEW.updated_at = OLD.updated_at THEN
          NEW.updated_at := now();
        END IF;
        RETURN NEW;
      SQL
    end

    def migrate
      # more complex example
      create_function "increment(i integer)", <<-SQL, returns: "integer"
        RETURN i + 1;
      SQL

      execute("SELECT increment(1)") #=> returns 2
    end
    ```

    ### Drop a function

    Removes the function from your database

    ```crystal
    def migrate
      drop_function "set_updated_at"
      drop_function "increment(i integer)"
    end
    ```

    ### Triggers

    Postgres triggers are callback functions which are automatically run based on some event
    that happens in your database.

    ### Create a trigger

    You must have the function you want to run already defined.

    ```crystal
    def migrate
      # Run the `set_updated_at()` SQL function before an update
      # to the users table
      create_trigger table_for(User), "set_updated_at"

      create_function "update_counts", <<-SQL
        NEW.view_count = OLD.view_count + 1
        RETURN NEW;
      SQL

      create_trigger :reports, "update_counts", callback: :after, on: [:insert, :update]
    end
    ```

    ## Migrations with Custom SQL

    Sometimes SQL can get really complicated, and sometimes it may just be something simple that Avram
    doesn't support just yet. Don't worry, you still have access to run raw SQL directly.

    Use the `execute` method to run any SQL directly.

    ```crystal
    def migrate
      execute <<-SQL
      CREATE TABLE admins (
        id character varying(18) NOT NULL,
        email character varying NOT NULL,
        password_digest character varying NOT NULL,
        created_at timestamp without time zone NOT NULL,
        updated_at timestamp without time zone NOT NULL
      );
      SQL
    end
    ```
    MD
  end
end
