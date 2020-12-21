class Guides::Database::IntroToAvramAndORMs < GuideAction
  guide_route "/database/intro-to-avram-and-orms"

  def self.title
    "Intro to Avram and ORMs"
  end

  def markdown : String
    <<-MD
    ## Avram

    [Avram](https://github.com/luckyframework/avram/) is the ORM Lucky uses for handling connections
    to your database, and wrapping the SQL mapping in a friendly Crystal class.
    An [Object Relational Mapping](https://en.wikipedia.org/wiki/Object-relational_mapping) or "ORM",
    is a simple way to translate SQL queries, and table schema in to an easy to use object.

    > Avram currently only supports PostgreSQL with no current plans to support any other RDBMS.
    > However, Lucky does not require you to use Avram if your requirements are a bit different.

    ### What does Avram mean?

    Originally called "LuckyRecord", the name change was decided because this ORM is not tied directly
    to the Lucky framework. You could choose to use it in any number of other Crystal frameworks.
    When deciding the name, we wanted something easily searchable, and meaningful. Thanks to all
    the suggestions from [the community](https://github.com/luckyframework/lucky_record/issues/238#issuecomment-426107202), we landed on Avram.

    [Henriette Avram](https://en.wikipedia.org/wiki/Henriette_Avram) was a computer programmer and systems
    analyst who developed the MARC format the international data standard for bibliographic and holdings
    information in libraries.

    ### What does Avram include?

    Every ORM will have a different pattern, and different set of tools included. With Avram, we took a
    pattern breaking out where business logic is stored vs. where database queries are handled. This pattern
    helps to keep code organized by it's purpose within your application. This includes `Models`, `Queries`,
    `Operations`, `Migrations`, and `Boxes`.

    ## Models

    Avram's models use classes to map each database table to a specific object. The naming convention for
    each model is to be the singular word as where the table name is the plural form.
    (e.g. `User` model, and `users` table.).

    A model inherits from `Avram::Model`; however, Lucky will generate an abstract class called `BaseModel`
    for you to inherit from. This abstraction layer allows you to apply special callbacks, attributes,
    or methods to all of your models.

    [Learn more about models](#{Guides::Database::Models.path})

    ## Queries

    Avram queries are classes that encompass querying the database. Once you have data in your database,
    you'll need a way to pull that data back out, and a Query class is that way! The naming convention
    for these objects is to use the referencing model's name followed by `Query`.
    (e.g. `User` model `UserQuery` query).

    Query objects inherit from a subclass of the model called `BaseQuery`. If you create a `User` model,
    Lucky will create a `User::BaseQuery` class for you, and your `UserQuery` object will inherit from that.
    (e.g. `UserQuery < User::BaseQuery`).

    [Learn more about queries](#{Guides::Database::Querying.path})

    ## Operations

    Avram operations are classes used for creating and updating records in the database.

    Similar to the `Query` object, these classes will inherit from a subclass of your model called
    `SaveOperation`. If you create a `User` model, Lucky will create a `User::SaveOperation` class for you.
    (e.g. `SaveUser < User::SaveOperation`).
    The naming convention for operations is to use an action of what this object does like save a user record.
    (e.g. `User` model, `SaveUser` operation).

    [Learn more about operations](#{Guides::Database::ValidatingSaving.path})

    ## Migrations

    You can think of migrations like [git](https://en.wikipedia.org/wiki/Git) for your database. These are
    classes that are scoped with a timestamp to allow you to update your database in versions as well as
    undo changes that you've made previously while keeping track of the order you made them in.

    Unlike the other files which live in your app's `src/` folder, these are located in the `db/migrations/`
    folder.

    [Learn more about migrations](#{Guides::Database::Migrations.path})

    ## Boxes

    Avram boxes are classes that you can use for generating data quick. The most common use cases are
    when writing tests for your application, and when seeding your database with some default or placeholder
    data.

    Boxes inherit from `Avram::Box` and follow the naming convention using the name of the model they
    reference followed by "Box". (e.g. `User` model, `UserBox` box) You'll find these located in your app's
    `spec/support/boxes/` folder.

    [Learn more about boxes](#{Guides::Testing::CreatingTestData.path})

    ## Alternate ORMs

    Even though Lucky uses Avram by default which only supports PostgreSQL, Lucky does not enforce
    the use of it. There may be cases where your application doesn't even need a database
    (e.g. luckyframework.org).

    If you want to take advantage of some of what Lucky has to offer, but your requirements need MySQL,
    SQLServer, or maybe something like RethinkDB / MongoDB, here's a few tips to integrating those.

    * Be sure to include the adapter in your `shard.yml` file
    * Still place your models in the `src/models` directory
    * `src/app_database.cr` can be deleted to avoid confusion
    * Avram must still be configured, but can be set as "unused" (see below)
    * Update your `config/database.cr` file with the new adapter's configuration settings

    ```crystal
    # config/database.cr
    class UnusedDB < Avram::Database
    end

    UnusedDB.configure do |settings|
      settings.credentials = Avram::Credentials.void
    end

    Avram.configure do |settings|
      settings.database_to_migrate = UnusedDB
    end

    # Configure your actual settings here
    MyOtherAdapter.configure do |settings|
      # Refer to that adapter's configuration guide
      settings.url = "my_other_adapter_url"
    end
    ```

    * Place migrations (if necessary) in `db/migrations/`.
    * Boxes, and Queries are specific to Avram Models, but you can still use [Basic Operations](#{Guides::Database::ValidatingSaving.path}).

    > If your app doesn't need a database, you should still set the `AppDatabase` credentials setting to
    > `Avram::Credentials.void`. Avram Operations can still be quite useful for things like contact forms,
    > or email subscribe forms. See [this website](https://github.com/luckyframework/website/blob/master/config/database.cr)
    > for an example.
    MD
  end
end
