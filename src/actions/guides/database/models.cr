class Guides::Database::Models < GuideAction
  guide_route "/database/models"

  def self.title
    "Database Models"
  end

  def markdown
    <<-MD
    ## Setting up a model

    Let's create a `User` model with `lucky gen.model User` and then add some
    columns. The name is a `String` and the age is an `Int32?`. The `age` column
    allows null because the type is nilable (designated by the `?`).

    > Note: we'll assume we ran a migration that created a name and age column.

    ```crystal
    # src/models/user.cr
    class User < BaseModel
      table :users do
        column name : String
        column age : Int32?
      end
    end
    ```

    > You can add a `?` to the end of any type to mark it as nilable.

    ### Column types

    You can use the following types in your columns.

    * `String` - `text` column type. In Postgres [`text` can store strings of any length](https://stackoverflow.com/questions/4848964/postgresql-difference-between-text-and-varchar-character-varying)
    * `Int32` - `int` column type.
    * `Time` - `timestamp` column type.
    * `Float64` - `decimal` column type.
    * `Bool` - `bool` column type.

    ## Using associations

    Right now you can define `has_many`, `has_one`, and `belongs_to` associations.

    ```crystal
    # Require the models we want to associate. If we don't we may get an
    # "Undefined constant" error because Lucky didn't load the associated models yet
    require "./supervisor"
    require "./task"
    require "./company"

    class User < BaseModel
      table :users do
        has_one supervisor : Supervisor
        has_many tasks : Task
        belongs_to company : Company
      end
    end

    # Will return the company associated with the User
    UserQuery.new.preload_company.find(1).company
    ```

    ### Making associations optional

    Sometimes associations are not required. To do that add a `?` to the end of the type.

    ```crystal
    belongs_to company : Company?
    ```

    > Make sure to make the column nilable in your migration as well: `belongs_to Company?`

    ### Has many through (many-to-many)

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

    > The associations *must* be declared on both ends (the Post and the Tag in
    this example), otherwise you will get a compile time error

    MD
  end
end
