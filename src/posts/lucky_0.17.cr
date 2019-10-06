class Lucky017Release < BasePost
  title "Lucky 0.17 has been released!"
  slug "lucky-0_17-release"

  def published_at : Time
    Time.utc(year: 2019, month: 8, day: 19)
  end

  def summary : String
    <<-TEXT
    Lucky v0.17 is a huge release with many enhancements to Avram, Lucky's ORM,
    as well as bug fixes and enhancements.
    TEXT
  end

  def content : String
    <<-MD
    Lucky v0.17 is now out and has support for the newest Crystal (v0.30)!

    Be sure to upgrade your version of Crystal, and take a look at our [UPGRADE NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-016-to-017) for help with migrating your app.

    ### What's new?

    We've made a ton of changes for this release, but we will highlight a few.
    You can see a full list through our [CHANGELOG](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-v017).

    ### Better primary key support

    Before this release, your primary key fields would be auto-generated as `Int32` for you with an option to
    use `UUID`. We've now added a new `primary_key` method which lets you specify the type. Avram supports a
    few different types now to include `Int16` and `Int64`.

    We have also set the default primary key to be `Int64` now.

    ```crystal
    def migrate
      create :users do
        # creates a primary key column named `id`
        primary_key id : Int64
      end
    end
    ```

    Along with the support for new types, you can now also name your primary key whatever you need.
    Generally you'd use the name `id` for your primary column, but there may be a case where you need to
    customize that.

    [Learn more about primary keys](#{Guides::Database::Migrations.path(anchor: Guides::Database::Migrations::ANCHOR_PRIMARY_KEYS)})

    ### JSON and Array support

    Postgres supports lots of different column types. Two really important ones used for complex structures
    are the `jsonb` and array column types. Lucky 0.17 adds support into specify your `jsonb` fields as
    `JSON::Any`, or use any of the basic postgres array fields.

    ```crystal
    table :users do
      column preferences : JSON::Any
      column tags : Array(String)
    end
    ```

    Now we can use these columns with our model.

    ```crystal
    user = UserQuery.first

    user.tags #=> ["vip", "prefers email"]
    user.preferences["theme_color"].as_s #=> "dark_mode"
    ```

    [Learn more about column types](#{Guides::Database::Models.path(anchor: Guides::Database::Models::ANCHOR_COLUMN_TYPES)})

    ### Multi-DB support

    Avram now supports multiple databases at the same time. You can have some models that connect to your
    primary database, and then a second set of models that connect to a legacy database if you wish.

    Example use cases for multiple databases:

    * Secondary for special finance reporting
    * Legacy DB support
    * One for API, One for CMS
    * Read / Write replica setup
    * Whatever your other databases are for, Avram is now better equipped to accommodate you.

    [Learn more about multi-db support](#{Guides::Database::DatabaseSetup.path(anchor: Guides::Database::DatabaseSetup::ANCHOR_MULTIPLE_DATABASES)})


    ### Polymorphic associations

    Support for polymorphic associations is now first-class with the `polymorphic` method. This
    method lets you specify your polymorphic association in a type-safe and friendly way.

    ```crystal
    class Comment < BaseModel
      table do
        # Note that both these `belongs_to` *must* be nilable
        belongs_to photo : Photo?
        belongs_to video : Video?

        # `commentable` could be a `photo` or `video`
        polymorphic commentable, associations: [:photo, :video]
      end
    end
    ```

    Your `Comment` model now has a `commentable` method which could return a `Photo` object, or a
    `Video` object. This ensures that your `commentable` is one of these associations.

    [Learn more about polymorphic associations](#{Guides::Database::Models.path(anchor: Guides::Database::Models::ANCHOR_POLYMORPHIC_ASSOCIATIONS)})

    ### New tasks

    Lucky comes with some built-in tasks for helping you do things like generate files, or run your
    migrations. Lucky 0.17 has added a few new ones to the mix.

    * `lucky db.migrations.status` - Run this to get a nice printout of your current migration status.
    See which migrations are still pending, and what your latest one was.
    * `lucky db.rollback_to MIGRATION_TIMESTAMP` - Rollback your migrations to the specific `MIGRATION_TIMESTAMP`.
    * `lucky db.verify_connection` - Test to ensure your database can connect properly.

    [Learn more about tasks](#{Guides::CommandLineTasks::BuiltIn.path})

    ### SaveOperations

    Previously named `Forms`, these have been renamed and revamped with a much cleaner, and
    easier to use API. We realized a lot of people would get confused when talking about `Forms`
    since you used them to interact with HTML forms. Now named `SaveOperation`, these give a bit
    more clarity. We also renamed `VirtualForm` to just `Operation`.

    [Learn more about operations](#{Guides::Database::ValidatingSaving.path})

    ### Parting words

    We're super stoked about this release, and hope you are too. Please give it a spin and help
    us find bugs so our next release is even more solid. If you find any issues, don't hesitate
    to [report the issue](https://github.com/luckyframework/lucky/issues). If you're unsure, just
    hop on [gitter chat](https://gitter.im/luckyframework/Lobby) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [gitter](https://gitter.im/luckyframework/Lobby).
    MD
  end
end
