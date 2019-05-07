class Guides::Database::ManagingAndMigrating < GuideAction
  guide_route "/database/managing-and-migrating"

  def self.title
    "Managing and Migrating the Database"
  end

  def markdown
    <<-MD
    ## Create or drop the database

    > If you're using Postgres.app for the database, make sure you have set up [CLI Tools](https://postgresapp.com/documentation/cli-tools.html).

    First you'll need to create a database using `lucky db.create`

    > The database name and settings can be changed in `config/database.cr`

    You can drop the database by calling `lucky db.drop`

    ## Seeding the database with data

    Lucky generates tasks for seeding the database with sample data and required data.
    There are instructions in the generated tasks that tell you how to use them.

    They are found in `tasks/create_sample_seeds.cr` and `tasks/create_required_seeds.cr`

    Run them with:

    * `lucky db.create_sample_seeds`
    * `lucky db.create_required_seeds`

    > These tasks are run when running `script/setup`, but nothing is run in
    production by default. If you have required seeds that need to be run for
    your app to work you should probably run `lucky db.create_required_seeds` after
    you deploy your app.

    ## Migration

    ### Introduction

    Migrations are an easy way to alter database schema in a convenient
    and easy way over time.

    You can think of migration as 'version control' for your database.

    ### Generating a new migration

    To create a new migration, use the `lucky gen.migration` command.

    > When you want to add or modify the database you can create a new migration using `lucky gen.migration {migration_name}`

    For example:

    `lucky gen.migration CreateUsers` or `lucky gen.migration AddAgeToUsers`

    The new migration file will be placed in the `db/migrations` directory.

    Each migration filename contains a timestamp which allows Lucky to determine the order of migrations.

    ### Migration Structure

    A migration class contains two methods: `migrate` and `rollback`.
    The `migrate` method is used to add new tables, columns, or indexes
    to your database, while the `rollback` method reverses the operations performed by the `migrate` method.

    > By default columns are required and do not allow NULL. You can add a `?` to
    the end of the type to make the column optional (allow NULL)

    ```crystal
    class CreateUsers::V20180305232601 < Avram::Migrator::Migration::V1
      def migrate
        create :users do
          # This column will allow NULL because it is marked with ?
          add avatar : String?
          # These columns will not allow NULL
          add name : String
          add email : String
          add password : String
        end

        # Run custom SQL with execute
        #
        # execute "CREATE UNIQUE INDEX things_title_index ON things (title);"
      end

      def rollback
        drop :things
      end
    end
    ```

    ### Running a migration

    To run all your outstanding migrations, run the `db.migrate` command.
    > `lucky db.migrate`

    ### Rolling back migration

    To rollback the latest migration command, use the `rollback` command.

    > `lucky db.rollback`

    ### Column Modifiers

    Column modifiers can be applied when creating or changing a column:

    * `index`: Adds an index for the column.

      ```crystal
        add first_name : String, index: true
      ```
    * `unique`: Specifies that a column's value should be unique.

      ```crystal
        add username : String, unique: true
      ```

    * `create_index`: Adds an index to a specified column.

      ```crystal
      create_index :users, :last_name, unique: true
      ```

    * `drop_index`: Removes an index to a specified column.

      ```crystal
        drop_index :users, :last_name, if_exists: true, on_delete: :cascade
      ```

    * `create_foreign_key`: Adds foreign key constraint to guarantee referential integrity.

      ```crystal
        create_foreign_key :comments, :users, on_delete: :cascade, column: :author_id, primary_key: :id
      ```

    * `default`: Allows to set a default value on the column.

      ```crystal
        add age : Int32, default: 1
      ```

    * `precision`:  Defines the precision for the decimal fields,
        representing the total number of digits in the number.

    * `scale`: Defines the scale for the decimal fields,
      representing the number of digits after the decimal point.

      ```crystal
        add salary : Float64, precision: 10, scale: 2
      ```

      Note: `precision` and `scale` are set only on columns with Float64 type.

    ## Creating and altering tables

    ```crystal
    # created_at, updated_at, and id are added automatically
    create :users do
      add name : String # will set the column to NULL FALSE
      add age : Int32? # will allow NULL values because of the nilable type
    end
    ```

    > Lucky currently supports `String, Int32, Bool, Float64, and Time`.

    ### Altering a table

    ```crystal
    alter :users do
      add phone : String
      remove :age

      # Sometimes you need things that Avram doesn't support
      execute "custom SQL"
    end
    ```

    ## Adding indices

    ```crystal
    # Add them while creating the column
    add email : String, index: true

    # Add a unique index
    add email : String, unique: true

    # Add an index after the fact
    # Note: Do this *inside* of a `create` or `alter` block
    add_index :email
    add_index :email, unique: true
    ```

    ## Adding associations

    * `add_belongs_to`: creates a one-to-one or many-to-many match with another
      model. This means that this class contains the foreign key.

      ```crystal
      def migrate
        create :comments do
          # This will create an author_id column with an index and a foreign_key
          # set to the users table.
          #
          # When the associated author is deleted, their comments are also deleted
          # because we set on_delete: :cascade
          add_belongs_to author : User, on_delete: :cascade
        end
      ```

    Note that the `on_delete` option *must* be set. Options are `:cascade`, `:restrict`,
    `:nullify` or `:do_nothing`

    ## Custom SQL

    For things Lucky doesn't support, you can use `execute` to run any sql you want.
    MD
  end
end
