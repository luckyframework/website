class Guides::Database::Models < GuideAction
  ANCHOR_SETTING_UP_A_MODEL = "perma-setting-up-a-model"
  ANCHOR_MODEL_ASSOCIATIONS = "perma-model-associations"
  ANCHOR_GENERATE_A_MODEL = "perma-generate-a-model"
  guide_route "/database/models"

  def self.title
    "Database Models"
  end

  def markdown
    <<-MD
    ## Introduction

    A Model is an object used to map a corresponding database table to a class.
    These objects model real-world objects to give you a better understanding on
    how they should interact within your application.

    Models in Lucky allow you to define methods associated with each column in the table.
    These methods return the value set in that column.

    Avram models also generate other classes you can use to save new records, and
    query existing ones.

    #{permalink(ANCHOR_GENERATE_A_MODEL)}
    ## Generate a model

    Lucky gives you a task for generating a model along with several other files that you
    will need for interacting with your database.

    Use the `lucky gen.model {ModelName}` task to generate your model. If you're generating a
    `User` model, you would run `lucky gen.model User`. Running this will generate a few files for you.

    * [User model](##{ANCHOR_SETTING_UP_A_MODEL}) - Located in `./src/models/user.cr`
    * [User form](#{Guides::Database::ValidatingSavingDeleting.path}) - Located in `./src/forms/user_form.cr`
    * [User query](#{Guides::Database::Querying.path}) - Located in `./src/queries/user_query.cr`
    * [User migration](#{Guides::Database::Migrations.path}) - Location in `./db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_create_users.cr`

    #{permalink(ANCHOR_SETTING_UP_A_MODEL)}
    ## Setting up a model

    Once you run the model generator, you'll have a file that looks like this

    ```crystal
    # src/models/user.cr
    class User < BaseModel
      table :users do
        # You will define columns here. For example:
        # column name : String
      end
    end
    ```

    Your model will inherit from `BaseModel` which is just an abstract class. You can use
    this to define methods all of your models should have access to.
    Next you'll see the `table` block that defines which table this model is connected to.

    ## Defining a column

    ### Default columns

    By default, Lucky will add a few columns to your model for you.

    * `id` - Your primary key column. Default `Int64`
    * `created_at` - default `Time` type.
    * `updated_at` - default `Time` type.

    To skip adding these, call the `skip_default_columns` macro in your model or `BaseModel`.

    ```crystal
    class BaseModel < Avram::Model
      skip_default_columns
    end
    ```

    Now your model won't define `id`, `created_at`, or `updated_at` fields. It will be up to you
    to specify your primary key field.

    ### Setting the primary key

    The primary key is `Int64` by default. If that's what you need, then everything is already set for
    you. If you need `Int32`, `Int16`, `UUID`, or your own custom set one, you'll need to update the
    `primary_key`.

    Setting your primary key with the `primary_key` method works the same as you did in
    your [migration](#{Guides::Database::Migrations.path(anchor: Guides::Database::Migrations::ANCHOR_PRIMARY_KEYS)}).

    ```crystal
    # src/models/user.cr
    class User < BaseModel
      # Sets the type for `id` to `UUID`
      table :users do
        primary_key id : UUID
      end
    end
    ```

    ### Adding a column

    Inside of the `table` block, you'll add the columns your model will define using the `column` method.

    ```crystal
    table :users do
      column email : String
      column active : Bool
      # This column can be `nil` because the type ends in `?`
      column ip_address : String?
      column last_active_at : Time
    end
    ```

    ### Column types

    Avram supports several types that map to Postgres column types.

    * `String` - `text` column type. In Postgres [`text` can store strings of any length](https://stackoverflow.com/questions/4848964/postgresql-difference-between-text-and-varchar-character-varying)
    * `Int32` - `int` column type.
    * `Int64` - `bigint` column type.
    * `Float` - `decimal` column type.
    * `Bool` - `boolean` column type.
    * `Time` - `timestamptz` column type.
    * `UUID` - `uuid` column type.
    * `JSON::Any` - `jsonb` column type.

    Any of your columns can also define "nillable" types by adding Crystal `Nil` Union `?`.
    This is if your column allows for a `NULL` value. (e.g. `column age : Int32?` allows an
    `int` or `NULL` value).

    #{permalink(ANCHOR_MODEL_ASSOCIATIONS)}
    ## Model associations

    In a [RDBMS](https://en.wikipedia.org/wiki/Relational_database) you may have tables that are
    related to each other. With Avram, we can associate two models to make some common queries a lot more simple.

    All associations will be defined in the `table` block. You can use `has_one`, `has_many`, and `belongs_to`.

    To avoid running in to an "Undefined Constant" error, be sure to require each model you want to associate.

    ```crystal
    require "./supervisor"
    require "./task"
    require "./company"
    class User < BaseModel
      table :user do
        has_one supervisor : Supervisor
        has_many tasks : Task
        belongs_to company : Company
      end
    end
    ```

    ## Belongs to

    A `belongs_to` will assume you have a foreign key column related to the other model defined
    as `{model_name}_id`.

    ```crystal
    table :users do
      column name : String

      # gives you the `company_id`, and `company` methods
      belongs_to company : Company
    end
    ```

    > When you create the migration, be sure you've set [add_belongs_to](#{Guides::Database::Migrations.path(anchor: Guides::Database::Migrations::ANCHOR_ASSOCIATIONS)}).

    You can preload these associations in your queries, and return the associated model.

    ```crystal
    # Will return the company associated with the User
    UserQuery.new.preload_company.find(1).company
    ```

    ### Optional association

    Sometimes associations are not required. To do that add a `?` to the end of the type.

    ```crystal
    belongs_to company : Company?
    ```

    > Make sure to make the column nilable in your migration as well: `add_belongs_to company : Company?`

    ## Has one (one to one)

    ```crystal
    table :users do
      has_one supervisor : Supervisor
    end
    ```

    This would match up with the `Supervisor` having `belongs_to`.

    ```crystal
    table :supervisors do
      belongs_to user : User
    end
    ```

    ## Has many (one to many)

    ```crystal
    table :users do
      has_many tasks : Task
    end
    ```

    > The name of the association should be the plural version of the model's name, and the type
    > is the model. (e.g. `Task` model, `tasks` association)

    ## Has many through (many to many)

    Let's say we want to have many tags that can belong to any number of posts.

    Here are the models:

    ```crystal
    # This is what will join the posts and tags together
    class Tagging < BaseModel
      table :taggings do
        belongs_to tag : Tag
        belongs_to post : Post
      end
    end

    class Tag < BaseModel
      table :tags do
        column name : String
        has_many taggings : Tagging
        has_many posts : Post, through: :taggings
      end
    end

    class Post < BaseModel
      table :posts do
        column title : String
        has_many taggings : Tagging
        has_many tags : Tag, through: :taggings
      end
    end
    ```

    > The associations *must* be declared on both ends (the Post and the Tag in this example),
    > otherwise you will get a compile time error
    MD
  end
end
