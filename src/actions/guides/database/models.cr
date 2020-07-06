class Guides::Database::Models < GuideAction
  ANCHOR_SETTING_UP_A_MODEL       = "perma-setting-up-a-model"
  ANCHOR_MODEL_ASSOCIATIONS       = "perma-model-associations"
  ANCHOR_GENERATE_A_MODEL         = "perma-generate-a-model"
  ANCHOR_COLUMN_TYPES             = "perma-column-types"
  ANCHOR_POLYMORPHIC_ASSOCIATIONS = "perma-polymorphic-associations"
  ANCHOR_USING_ENUMS              = "perma-using-enums"
  guide_route "/database/models"

  def self.title
    "Database Models"
  end

  def markdown : String
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
    * [SaveUser Operation](#{Guides::Database::ValidatingSaving.path}) - Located in `./src/operations/save_user.cr`
    * [User query](#{Guides::Database::Querying.path}) - Located in `./src/queries/user_query.cr`
    * [User migration](#{Guides::Database::Migrations.path}) - Location in `./db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_create_users.cr`

    #{permalink(ANCHOR_SETTING_UP_A_MODEL)}
    ## Setting up a model

    Once you run the model generator, you'll have a file that looks like this

    ```crystal
    # src/models/user.cr
    class User < BaseModel
      table do
        # You will define columns here. For example:
        # column name : String
      end
    end
    ```

    Your model will inherit from `BaseModel` which is an abstract class that
    defines what database this model should use, and optionally customizes
    the default columns a model has. You can also use `BaseModel` to define
    methods all of your models should have access to.

    Next you'll see the `table` block that defines which table this model is
    connected to and what columns are added.

    ### Mapping a model to a table

    By default the `table` macro will use the underscored and pluralized
    version of the model's class name. So `CompletedProject` would have the
    table name `:completed_projects`.

    ```crystal
    class CompletedProject < BaseModel
      # Will use :completed_projects as the table name
      table do
      end
    end
    ```

    However, if you want to use a different table name you can provide to to the
    `table` macro:

    ```crystal
    class CompletedProject < BaseModel
      table :legacy_completed_projects do
      end
    end
    ```

    ## Defining a column

    ### Default columns

    By default, Lucky will add a few columns to your model for you.

    * `id` - Your primary key column. Default `Int64`
    * `created_at` - default `Time` type.
    * `updated_at` - default `Time` type.

    ### Customizing the default columns

    To change your defaults, define a macro called `default_columns` in your
    `BaseModel` and add whatever columns should automatically be added:

    ```crystal
    # In src/models/base_model.cr
    abstract class BaseModel < Avram::Model
      macro default_columns
        # Defines a custom primary key name and type
        primary_key custom_key : UUID

        # adds the `created_at` and `updated_at`
        timestamps
      end
    end
    ```

    ### Skipping default columns

    If you have a specific model that needs different columns than the
    defaults, call the `skip_default_columns` macro at the top of the model
    class.

    Now your model won't define `id`, `created_at`, or `updated_at` fields. It will be up to you
    to specify your primary key field.

    ```crystal
    class CustomModel < Avram::Model
      skip_default_columns

      table do
        primary_key something_different : Int64
      end
    end
    ```

    ### Setting the primary key

    The primary key is `Int64` by default. If that's what you need, then everything is already set for
    you. If you need `Int32`, `Int16`, `UUID`, or your own custom set one, you'll need to update the
    `primary_key` in your `BaseModel` or set one in the `table` macro.

    Setting your primary key with the `primary_key` method works the same as you did in
    your [migration](#{Guides::Database::Migrations.path(anchor: Guides::Database::Migrations::ANCHOR_PRIMARY_KEYS)}).

    ```crystal
    # src/base_model.cr
    abstract class BaseModel < Avram::Model
      macro default_columns
        # Sets the type for `id` to `UUID`
        primary_key id : UUID
        timestamps
      end
    end
    ```

    ### Adding a column

    Inside of the `table` block, you'll add the columns your model will define using the `column` method.

    ```crystal
    table do
      column email : String
      column active : Bool
      # This column is optional (can be `nil`) because the type ends in `?`
      column ip_address : String?
      column last_active_at : Time
    end
    ```

    #{permalink(ANCHOR_COLUMN_TYPES)}
    ### Column types

    Avram supports several types that map to Postgres column types.

    * `String` - `text` column type. In Postgres [`text` can store strings of any length](https://stackoverflow.com/questions/4848964/postgresql-difference-between-text-and-varchar-character-varying)
    * `Int16` - `smallint` column type.
    * `Int32` - `integer` column type.
    * `Int64` - `bigint` column type.
    * `Float64` - `numeric` column type.
    * `Bool` - `boolean` column type.
    * `Time` - `timestamp with time zone` (`timestamptz`) column type.
    * `UUID` - `uuid` column type.
    * `JSON::Any` - `jsonb` column type.
    * `Array(T)` - `[]` column type where `T` is any other supported type.
    * Avram Enum - [see using enums](##{ANCHOR_USING_ENUMS})

    Any of your columns can also define "nilable" types by adding Crystal `Nil` Union `?`.
    This is if your column allows for a `NULL` value. (e.g. `column age : Int32?` allows an
    `int` or `NULL` value).

    ### Additional postgres types

    Postgres supports a lot more types than what Avram does out of the box. If you need access to a
    type that [crystal-pg](https://github.com/will/crystal-pg) supports that isn't listed above,
    you can add in support for your app.

    Let's take postgres's `double precision` type for example. This currently maps to `Float64`, but
    Lucky maps `numeric` to `Float64`. To use the `double precision` type, create an alias.

    ```crystal
    alias Double = Float64

    # then in your model

    table do
      column price : Double
    end
    ```

    > Avram is constantly being updated, and some types may not "patch" as easily. If you tried this
    > method, and it doesn't work for you, be sure to [open an issue](https://github.com/luckyframework/avram/issues) so we can get support for that
    > as soon as possible.

    #{permalink(ANCHOR_USING_ENUMS)}
    ## Using enums

    [Enums](https://crystal-lang.org/reference/syntax_and_semantics/enum.html) are a way to map an Integer to a named value. Computers handle
    numbers better, but people handle words better. This is a happy medium between the two. For example, a user status may be "active", but we
    store it as the number 1.

    Avram comes with an `avram_enum` macro to help using Crystal Enum while maintaining Lucky's type-safety with the database.

    ```crystal
    class User < BaseModel

      avram_enum Status do
        # Default value starts at 0
        Guest   # 0
        Active  # 1
        Expired # 2
      end

      avram_enum Role do
        # Assign custom values
        Member = 1
        Admin = 2
        Superadmin = 3
      end

      table do
        column status : User::Status
        column role : User::Role
      end
    end
    ```

    The column will return an instance of your `avram_enum`. (e.g. `User::Role.new(:admin)`). This gives
    you access to a few helper methods for handling the enum.

    ```crystal
    User::Status.new(:active).value #=> 1
    User::Role.new(:superadmin).value #=> 3

    user = UserQuery.new.first
    user.status.value #=> 1
    user.status.active? #=> true

    user.role.value #=> 3
    user.role.member? #=> false
    ```

    To learn more about using enums, read up on [saving with enums](#{Guides::Database::ValidatingSaving.path(anchor: Guides::Database::ValidatingSaving::ANCHOR_SAVING_ENUMS)})
    and [querying with enums](#{Guides::Database::Querying.path(anchor: Guides::Database::Querying::ANCHOR_QUERYING_ENUMS)}).

    #{permalink(ANCHOR_MODEL_ASSOCIATIONS)}
    ## Model associations

    In a [RDBMS](https://en.wikipedia.org/wiki/Relational_database) you may have tables that are
    related to each other. With Avram, we can associate two models to make some common queries a lot more simple.

    All associations will be defined in the `table` block. You can use `has_one`, `has_many`, and `belongs_to`.

    ```crystal
    class User < BaseModel
      table do
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
    table do
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
    table do
      has_one supervisor : Supervisor
    end
    ```

    This would match up with the `Supervisor` having `belongs_to`.

    ```crystal
    table do
      belongs_to user : User
    end
    ```

    ## Has many (one to many)

    ```crystal
    table do
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
      table do
        belongs_to tag : Tag
        belongs_to post : Post
      end
    end

    class Tag < BaseModel
      table do
        column name : String
        has_many taggings : Tagging
        has_many posts : Post, through: :taggings
      end
    end

    class Post < BaseModel
      table do
        column title : String
        has_many taggings : Tagging
        has_many tags : Tag, through: :taggings
      end
    end
    ```

    > The associations *must* be declared on both ends (the Post and the Tag in this example),
    > otherwise you will get a compile time error

    #{permalink(ANCHOR_POLYMORPHIC_ASSOCIATIONS)}
    ## Polymorphic associations

    [Polymorphism](https://en.wikipedia.org/wiki/Polymorphism_(computer_science)) describes
    the concept that objects of different types can be accessed through the same interface.

    This allows us to have a single method to define an association, but that method can return
    many different types. A bit confusing, but best explained with some code!

    ```crystal
    class Photo < BaseModel
      table do
        has_many comments : Comment
      end
    end

    class Video < BaseModel
      table do
        has_many comments : Comment
      end
    end

    class Comment < BaseModel
      table do
        # Note that both these `belongs_to` *must* be nilable
        belongs_to photo : Photo?
        belongs_to video : Video?

        # Now `commentable` could be a `photo` or `video`
        polymorphic commentable, associations: [:photo, :video]
      end
    end
    ```

    And to use it

    ```crystal
    photo = SavePhoto.create!
    comment = SaveComment.create!(photo_id: photo.id)

    comment.commentable == photo
    ```

    The `Comment` model now has a `commentable` method which could return a `photo` object
    or a `video` object depending on which was associated.
    <!-- go go polymorphin power rangers -->
    For each polymorphic association, you'll need to add a `belongs_to`. This helps to keep
    our polymorphic associations type-safe! [See migrations](#{Guides::Database::Migrations.path(anchor: Guides::Database::Migrations::ANCHOR_ASSOCIATIONS)}) for `add_belongs_to`.

    You'll also note that the `belongs_to` has nilable models. This is required for the polymorphic
    association. Even though these are set as nilable, the association still requires at least 1 of the
    `associations` to exist. This means that `commentable` is never actually `nil`.

    If you need this association to be fully optional where `commentable` could be `nil`, you'll add the
    `optional` option.

    ```crystal
    # commentable can now be nil
    polymorphic commentable, optional: true, associations: [:photo, :video]
    ```

    ### Preloading polymorphic associations

    Since the polymorphic associations are just regular `belongs_to` associations with some sweet
    helper methods, all of the [preloading](#{Guides::Database::Querying.path(anchor: Guides::Database::Querying::ANCHOR_PRELOADING)}) still exists.

    ```crystal
    comment = CommentQuery.new.preload_commentable
    comment.commentable #=> Safely access this association
    ```

    To skip preloading the polymorphic association, just add a bang `!`.

    ```crystal
    comment = CommentQuery.first
    comment.commentable! #=> no preloading required here
    ```
    MD
  end
end
