class IntroducingTheLuckyBlog < BasePost
  title "Introducing the Lucky Blog"
  slug "introducing-lucky"

  def published_at
    Time.utc(year: 2019, month: 5, day: 16)
  end

  def summary
    <<-TEXT
    Before now Lucky's updates were scattered across various mediums, but not
    anymore. We've got brand new guides, mobile friendly design and a blog.
    TEXT
  end

  def content
    <<-MD
    We're excited to announce a brand new website and blog for Lucky

    The rest of this is just testing *formatting*.

    ## Create or drop the database

    First you'll need to create a database using `lucky db.create`

    You can drop the database by calling `lucky db.drop`

    ## Seeding the database with data

    Lucky generates tasks for seeding the database with sample data and required data.
    There are instructions in the generated tasks that tell you how to use them.

    They are found in `tasks/create_sample_seeds.cr` and `tasks/create_required_seeds.cr`

    Run them with:

    * `lucky db.create_sample_seeds`
    * `lucky db.create_required_seeds`

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

    MD
  end
end
