class Lucky120Release < BasePost
  title "Another milestone reached with Lucky 1.2.0"
  slug "lucky-1_2_0-release"

  def published_at : Time
    Time.utc(year: 2024, month: 4, day: 24)
  end

  def summary : String
    <<-TEXT
    We're well in to 2024 now. Crystal 1.12 is out,
    and so is Lucky 1.2.0. Let's check out all
    of the great new features and updates
    TEXT
  end

  def content : String
    <<-MD
    Lucky v1.2.0 has been released with lots of great new updates and features.

    Read through the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)
    for all of the changes, but we will discuss some of the highlights here.

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-110-to-120).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=1.1.0&to=1.2.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    ### Installing Lucky on Windows

    While Lucky doesn't quite have 100% Windows compatibility, we do have a way for you to start testing things
    by installing Lucky on Windows via [Scoop](https://scoop.sh/).

    This is a huge step forward for Crystal on Windows in general. As Crystal's support for Windows grows, we
    will need to ensure the entire ecosystem is right there. You can check out our official [scoop bucket](https://github.com/luckyframework/scoop-bucket)
    for instructions on installing, or to help contribute.

    ### DB.mapping replaced with DB::Serializable

    Avram models use [crystal-db](https://github.com/crystal-lang/crystal-db/) under the hood to build the
    columns. Previously we used `DB.mapping` to construct the columns, but as of [this commit](https://github.com/crystal-lang/crystal-db/),
    that way has been deprecated in favor of using `DB::Serializable`. This now keeps things consistent with `JSON::Serialzable` and
    `YAML::Serializable`, but it does come with a small breaking change.

    The `DB::Serializable` is a module that is included in `Avram::Model`. It works by mapping the instance variables to columns
    in the database. This also means that any instance variable you've defined as custom will be mistaken for a database related column.
    To avoid this, you will need to add the annotation `@[DB::Field(ignore: true)]` to any instance variable you may have added
    in your model.

    ```crystal
    class MyModel < BaseModel
      table do
        column name : String
      end

      @[DB::Field(ignore: true)]
      property special_field : String
    end
    ```

    ### Lots of new Critera methods

    The Criteria methods in Avram are query methods used around specific column types. For example,
    the `String` column types have criteria methods `upper` and `lower` which allow you to transform
    the column with `UPPER(col)` or `LOWER(col)` which can be used for special comparrisons.

    In this release, we have added a LOT more. The `String` type added `length` and `reverse`.
    `Int` and `Float` types received a few `abs`, `ceil`, and `floor`.

    ```crystal
    # Find all users that have a username length of 8
    UserQuery.new.username.length.eq(8)

    # Find all cards with a palindrome
    CardQuery.new.title.reverse.eq("tacocat")

    # Find all purchases where the amount rounded up is greater than 5
    PurchaseQuery.new.amount.ceil.gt(5)

    # Turn a negative number in to positive, and use in your query
    PointQuery.new.x_position.abs.lte(1)
    ```

    To add to these great methods, we've also added `JSON::Any` critera methods. Querying jsonb fields
    can be a bit tricky, and Avram now allows you to avoid a few unsafe raw WHERE queries by using type-safe ones.

    ```crystal
    # where the preferences jsonb has the key 'theme'
    UserQuery.new.preferences.has_key("theme")

    # where the preferences jsonb has the key 'theme' or the key 'color'
    UserQuery.new.preferences.has_any_keys(["theme", "color"])

    # where the preferences jsonb has the key 'theme' and the key 'color'
    UserQuery.new.preferences.has_all_keys(["theme", "color"])

    # where the preferences jsonb contains the JSON {"theme": "dark"}
    UserQuery.new.preferences.includes({theme: "dark"})

    # where the preferences jsonb is found in this json document
    UserQuery.new.preferences.in(large_json_document)
    ```

    Finally, `String` also received a few more Criteria related to Full-Text searching.

    Convert a `String` column `to_tsquery` or `to_tsvector` by using those methods names in
    conjunction with the new `match` method.

    ```crystal
    # SELECT * FROM profiles WHERE TO_TSVECTOR(description) @@ TO_TSQUERY('Lucky')
    ProfileQuery.new.description.to_tsvector.match("Lucky")
    ```

    ### New migration methods

    Migrations received a few updates. You can now run your `create` and `alter` conditionally
    with `if_not_exists` and `if_exists` respectively.

    ```crystal
    # Only create the table if it does not already exist
    create table_for(Server), if_not_exists: true do
      add hostname : String
    end
    ```

    You can now ignore the index created on `add_belongs_to` by specifying `index: false`.

    ```crystal
    alter table_for(Reaction), if_exists: true do
      add_belongs_to user : User?, index: false
      add_belongs_to friend : User?, index: false
    end
    ```

    This will allow you to create a custom unique index utilizing multiple columns instead of separate indexes on each column.

    We've also added the `create_sequence` and `drop_sequence` helpers.

    ```crystal
    def migrate
      create_sequence table_for(Account), :number
    end

    def rollback
      drop_sequence table_for(Account), :number
    end
    ```

    ### The IGNORE constant

    In Avram, the attributes defined on operations are a union of the type you specified, and `Avram::Nothing`.
    The `Avram::Nothing` type is used as a way to differentiate between you intending to update a column to `nil`
    by passing in a `nil` value versus a `nil` value existing in params but with no intention of updating the column.

    Previously, each attribute would define a default value of `Avram::Nothing.new`. The larger your application grew,
    the more instances of `Avram::Nothing` you would have. These all have now been replaced with a single constant `IGNORE`.

    Use the `IGNORE` constant when you want to fallback to ignoring a column in a SaveOperation.

    ```crystal
    # If `new_email.presence` is nil, then just ignore this update
    UpdateUserEmail.update!(
      current_user,
      email: new_email.presence || IGNORE
    )
    ```

    ### Email attachments

    [Carbon](https://github.com/luckyframework/carbon/pull/88) received a nice update with the addition of
    attachment support.

    ```crystal
    class BirthdayEmail < BaseEmail
      def initiailize(@recipient : Carbon::Emailable)
        @image = File.open("birthday_cake.png")
      end

      subject "Happy Birthday"
      to @recipient
      templates html
      attachment cake

      def cake
        {
          io: @image,
          file_name: "birthday_cake.png",
          mime_type: "image/png"
        }
      end

      def after_send(result)
        @image.close
      end
    end
    ```

    ### even more!

    There were quite a few updates in this release, and unfortunately we can't show them all. Here's several
    more that were added just for an encore!

    * Support for Array(Enum) columns
    * Support for String primary keys
    * Firefox LuckyFlow driver
    * Added option to `lucky gen.secret_key` task
    * More CockroachDB compatibility
    * A materialized view helper method `refresh_view`
    * Custom column converters
    * DB connection retries
    * Route building optimizations
    * Compilation time printed during development
    * Bug fixes

    ## Parting words

    Thanks to all of the new developers giving Lucky a shot. The more people that try it out,
    the better we can make the framework. If you're using Lucky in production, and would like
    to add your application to our [Awesome Lucky](https://luckyframework.org/awesome) "built-with"
    section, feel free to open an issue on the [Website](https://github.com/luckyframework/website/issues)
    or a PR!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [X/Twitter](https://twitter.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
