class Guides::Database::Migrations < GuideAction
  ANCHOR_ASSOCIATIONS = "perma-associations"
  ANCHOR_PRIMARY_KEYS = "perma-primary-keys"
  guide_route "/database/migrations"

  def self.title
    "Migrations"
  end

  def markdown
    <<-MD
    ## Migrating Data

    ### Introduction

    You can think of migrations like version control for your database.
    These are classes that are scoped with a timestamp to allow you to update your database
    in versions as well as undo changes that you've made previously.

    ### Generating a new migration

    To create a new migration, run the `lucky gen.migration {PurposeOfMigration}`.
    (e.g. If you need to add a `name` column to `users`, you would run `lucky gen.migration AddNameToUsers`).
    This would generate a `db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_name_to_users.cr` file.

    > When you generate a new model, a migration file is created for you.

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

    ### DB Tasks

    Lucky comes with several tasks you can run for handling your migrations.

    * `db.migrate` - Run all pending migrations.
    * `db.migrate.one` - Run only the next pending migration.
    * `db.redo` - Rollback to the previous migration, then re-run the last migration again.
    * `db.rollback` - Undo the last migration ran.
    * `db.rollback_all` - Undo all of the migrations back to the beginning.

    ## Create table

    Use the `create` method for creating a table. You will place all of the table definitions
    inside of the `create` block.

    ```crystal
    def migrate
      create :users do
        # add column definitions here
      end
    end
    ```

    ### Special columns

    When adding in columns, you'll use the [add](#add-column) method in your `create` block, but there are
    some special considerations.

    ```crystal
    create :users do
      # for adding your primary key
      primary_key id : Int64

      # adds `created_at : Time`, and `updated_at : Time` columns
      add_timestamps
    end
    ```

    #{permalink(ANCHOR_PRIMARY_KEYS)}
    ## Primary keys

    You will need to specify your primary key in your `create` block using the `primary_key` method.
    Avram currently supports these key types:

    * `Int16` - maps to postgres `smallserial`.
    * `Int32` - maps to postgres `serial`.
    * `Int64` - maps to postgres `bigserial`.
    * `UUID` - maps to postgres `uuid`. Generates V4 UUID

    To specify your primary key, you'll use the `primary_key` method.

    ```crystal
    def migrate
      create :users do
        # creates a primary key column named `id`
        primary_key id : Int64
      end
    end
    ```

    > Avram also supports changing your primary key column name. (e.g. `primary_key custom : Int16`)

    ## Drop table

    To drop a table, use the `drop` method.

    ```crystal
    def migrate
      drop :users
    end
    ```

    > If your `migrate` method runs `create`, then the `rollback` method should run `drop`.

    ## Alter table

    If your table exists, and you need to make changes to *this* table, use the `alter` method.
    All of your changes will go in the `alter` block.

    ```crystal
    def migrate
      alter :users do
        remove :old_field
      end
    end
    ```

    ## Add column

    To add a new column, you'll use the `add` method inside of a [`create`](#create-table)
    or [`alter`](#alter-table) block.

    ```crystal
    create :users do
      add email : String
      add birthdate : Time
      add login_count : Int32, default: 0
    end
    ```

    ```crystal
    alter :users do
      add last_known_ip : String?
    end
    ```

    ### Datatypes

    There are a few different datatypes that you can use to declare the column type.

    * `String` - Maps to postgres `text`.
    * `Int16` - Maps to postgres `smallint`.
    * `Int32` - Maps to postgres `int`.
    * `Int64` - Maps to postgres `bigint`.
    * `Time` - Maps to postgres `timestamptz`.
    * `Bool` - Maps to postgres `boolean`.
    * `Float64` - Maps to postgres `decimal`. With options for precision and scale.
    * `UUID` - Maps to postgres `uuid`.
    * `JSON::Any` - Maps to postgres `jsonb`.
    * `Array(T)` - Maps to postgres array fields where `T` is any of the other datatypes.

    ### Advanced Options

    The `add` method takes several options for further customization when adding a field.

    * `index` - `false` by default. When `true`, this will create an index on this column.
    * `using` - `:btree` by default. The index method to use when an index is created.
    * `unique` - `false` by default. When `true`, postgres will enforce a unique constraint on this field.
    * `default` - The default value to use for this column.

    ```crystal
    create :users do
      add email : String, index: true, unique: true
      add login_count : Int32, default: 0
    end
    ```

    ## Using 'fill_existing_with'

    When using the `add` method inside an `alter` block, there's an additional option `fill_existing_with`.

    If your column is required, you will need to set a default value on all records otherwise you'll have errors.

    ```crystal
    alter :users do
      add active : Bool, default: true, fill_existing_with: true
      add otp_code : String, fill_existing_with: "fake-otp-code-123"
    end
    ```

    > You can also use `fill_existing_with: :nothing` if your table is empty.

    If a static value will not work, try this:

    * If you have not yet released the app, consider using `fill_existing_with: :nothing`
      and dropping the database `lucky db.drop` and recreating it with `lucky db.create && lucky db.migrate`.
    * Consider making the type nilable `add otp_code : String?`, then fill the values with whatever value you need.
      Then later make it required with `make_required :otp_code`

    ``` crystal
    def migrate
      alter :users do
        # Add nullable column first
        add otp_code : String?
      end

      # Then add values to it
      UserQuery.new.each do |user|
        User::SaveOperation.udpate!(user, otp_code: CodeGenerator.generate)
      end

      # Then make it non-nullable
      make_required :otp_code
    end
    ```

    ## Remove column

    The `remove` method must go in the `[alter](#alter-table)` block.

    ```crystal
    alter :users do
      remove :middle_name
      remove :last_login_ip
    end
    ```

    ## Add index

    The easiest way is to add the `index: true` option on the `add` method.
    However, if you're adding indicies after the table is created, you can use the `create_index` method.

    ```crystal
    def migrate
      create_index :users, [:status], unique: false
    end
    ```

    ## Remove index

    Use the `drop_index` method to remove the index.

    ```crystal
    def migrate
      drop_index :users, [:status]
    end
    ```

    #{permalink(ANCHOR_ASSOCIATIONS)}
    ## Associations

    If your tables have a one-to-many or a many-to-many relation, you can use these
    methods to create a foreign key constraint, or remove that constraint from your tables.

    [Learn more about associations with models](#{Guides::Database::Models.path(anchor: Guides::Database::Models::ANCHOR_MODEL_ASSOCIATIONS)})

    ### Add belongs_to

    The `add_belongs_to` method will create that foreign key constraint.

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
    end
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
      create :comments, primary_key_type: :uuid do
        add_belongs author : User, on_delete: :cascade, foreign_key_type: Avram::Migrator::PrimaryKeyType::UUID
      end
    end
    ```

    ### Remove belongs_to

    When you need to remove the association, you can use `remove_belongs_to`.

    ```crystal
    def migrate
      alter :comments do
        # This will drop the author_id column
        remove_belongs_to :author
      end
    end
    ```

    ## Custom SQL

    Sometimes SQL can get really complicated, and sometimes it may just be something simple that Avram doesn't support just yet. Don't worry, you still have access to run raw SQL directly.

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

    > You can also use `execute` for doing things like `CREATE FUNCTION` or `CREATE EXTENSION`.
    MD
  end
end
