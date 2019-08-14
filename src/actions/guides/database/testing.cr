class Guides::Database::Testing < GuideAction
  guide_route "/database/testing"

  def self.title
    "Creating Test Data"
  end

  def markdown
    <<-MD
    ## Introduction

    A Box is a class that allows you to easily create test data.

    Even though a Box is generally used for test data, you can also use it to seed your database with
    development data as mentioned in [database setup](#{Guides::Database::DatabaseSetup.path(anchor: Guides::Database::DatabaseSetup::ANCHOR_SEEDING_DATA)}).

    ## Creating a Box

    Boxes will live in your `spec/support/boxes/` directory. Each box will inherit from `Avram::Box`,
    and take the naming convention of the name of your model followed by `Box`.
    (e.g. a `User` model and `UserBox`)

    ```crystal
    # spec/support/boxes/post_box.cr
    class PostBox < Avram::Box
      def initialize
        title "My Post"
        body "Test Body"
      end
    end
    ```

    ### Box model attributes

    Each box will have access to the associated model's column fields. In the example `PostBox`, if
    our `Post` model has a `column title : String` and `column body : String`, then the box will have
    a `title` method and `body` method.

    These methods take an argument of the default value you want to set for that box.

    ```crystal
    class PostBox < Avram::Box
      def initialize
        title "Milk was a bad choice"
        body "Every post created from this PostBox will default to these values"
      end
    end
    ```

    A `Post` will usually have more columns like `id`, `created_at`, and `updated_at`. We can omit
    these since Avram will handle setting values on these for us. We can also omit any other fields
    that are nilable by default.

    ### Sequences

    Your model may have a unique constraint on a field like a `Post` title, for example. In this case,
    you can use the `sequence` method to auto-increment a number on to your default value ensuring it will
    be unique.

    ```crystal
    class PostBox < Avram::Box
      def initialize
        title sequence("My new blog post")
      end
    end
    ```

    The first time a `PostBox` is created, the `title` will be set to `"My new blog post-1"`. The next time
    one is created, the `title` will be set to `"My new blog post-2"`, and so on.

    > Sequences always return a `String`. For sequence type values on other types, you'll need to
    > implement those yourself.

    ## Associations with boxes

    When you create a Box, you may want to have an association already set for you. In this case,
    you'll just use that association's box to set the `foreign_key` value.

    ```crystal
    class PostBox < Avram::Box
      def initialize
        title sequence("post-title")
        body "blah"
        user_id UserBox.create.id
      end
    end
    ```

    > Creating a Box returns an instance of that model, which means you have access to all of the model
    > methods.

    ## Saving records

    As shown previously, a Box has a `create` method which saves the record to your database. A Box is
    essentially a fancy wrapper around [SaveOperation](#{Guides::Database::ValidatingSaving.path}).

    Boxes give you access to two helpful class methods `create` and `create_pair`.

    ### Box.create

    This will create a `Post`, and store it in your database, then return the instance of `Post`.
    It will use the defaults you defined in your `initialize` method of `PostBox`.

    ```crystal
    post = PostBox.create
    post.title #=> "post-title-1"

    post2 = PostBox.create
    post2.title #=> "post-title-2"
    ```

    ### Overriding data

    When you need to override the defaults previously set, you'll pass a block to `create`.

    ```crystal
    PostBox.create do |box|
      box.title("Draft")
      box.body("custom body")
    end
    ```

    Thanks to Crystal's [short one-argument syntax](https://crystal-lang.org/reference/syntax_and_semantics/blocks_and_procs.html#short-one-argument-syntax), we can shorten this with

    ```crystal
    PostBox.create &.title("Draft").body("custom body")
    ```

    ### Box.create_pair

    It may be common for you to need to create more than 1 test object at a time. For this, you can use
    the `create_pair` method to create 2 test objects!.

    ```crystal
    PostBox.create_pair
    ```

    > The big difference here is that `create_pair` will return `nil`, and you can't override
    > the default data. Use this as "set it and forget it".

    ## Testing with Boxes

    Once you have your boxes setup, and you're ready to test, you'll add your tests to your `spec/` directory.

    ```crystal
    # spec/post_spec.cr
    require "./spec_helper"

    describe Post do
      it "has 2 posts" do
        PostBox.create_pair

        query = PostQuery.new.select_count
        query.should eq 2
      end

      it "sets a custom post title" do
        post = PostBox.create &.title("Custom Post")

        query = PostQuery.new.title("Custom Post")
        query.first.should eq post
      end
    end
    ```
    MD
  end
end
