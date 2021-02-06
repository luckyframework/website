class Lucky026Release < BasePost
  title "Lucky v0.26 Released and ready to go!"
  slug "lucky-0_25-release"

  def published_at : Time
    Time.utc(year: 2021, month: 2, day: 8)
  end

  def summary : String
    <<-TEXT
    Lucky v0.26 is the latest and just another
    step closer to our 1.0 goal!
    TEXT
  end

  def content : String
    <<-MD
    [Lucky v0.26](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-026)
    is out, and just like 0.25.0, this was another huge release! So many bug fixes, and even a few
    more goodies!

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-025-to-026).

    Or you can view the changes using [LuckyDiff](https://luckydiff.com/?from=0.25.0&to=0.26.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    ### `Box` is now `Factory`

    In [#614 of Avram](https://github.com/luckyframework/avram/pull/614) we renamed `Avram::Box` to `Avram::Factory`.
    Even though this doesn't really change how the code works, it's still a pretty big change due to being a breaking-change,
    as well as that's a lot of filenames and places to change code. You can read [the discussion](https://github.com/luckyframework/lucky/discussions/1282)
    on this decision, but basically, the term "Factory" is more common for newcomers, and apparently Crystal already has a [Box class](https://crystal-lang.org/api/0.35.1/Box.html).

    Here's just a quick example of the change:

    ```crystal
    # BEFORE 0.26.0 UPDATE
    # spec/support/boxes/user_box.cr
    class UserBox < Avram::Box
      def initialize
        email "test@test.com"
      end
    end

    # AFTER 0.26.0 UPDATE
    # spec/support/factories/user_factory.cr
    class UserFactory < Avram::Factory
      def initialize
        email "test@test.com"
      end
    end
    ```

    ### Reverted the `after_completed` callback

    In the [0.25.0 Release](#{Lucky025Release.slug}) we added the `after_completed` callback to `Avram::SaveOperation` in order to handle a specific edge case.
    This case was when calling `SaveSomeObject.update(...)`, if there were no changes to that object, then you had no callbacks that would run. The `after_completed`
    callback fixed this issue.

    For this release, we've made the decision to just always run `after_save` and `after_commit` whether your object has changes to commit to the database or not.
    The benefit of code running how you'd expect outweighed any performance benefit we gained from not running them.

    [Read more](https://github.com/luckyframework/avram/pull/612) on this change.

    ### New CLI tasks

    We LOVE using the CLI tasks because they make so many things so much easier! Lucky 0.26.0 adds in two new tasks

    * `lucky gen.task SomeTask` - Now a task to generate a new task! [read the PR](https://github.com/luckyframework/lucky/pull/1322)
    * `lucky db.console` - A task to enter the `psql` console without having to type your credentials [read the PR](https://github.com/luckyframework/avram/pull/592)

    ### Delete Operations

    https://github.com/luckyframework/avram/pull/573

    ### CIText Support

    This was new to some of us that had never even heard of "citext" before this. The "citext" column in postgres is "Case-Insensitive Text". This allows you to
    store a string in your database, and do lookups against it without the need to do something like `"WHERE LOWER(email) = ?", email.downcase`. Instead, your
    users could spell their email like "LucKyDawG@gmAIl.com" and still log in with "luckydawg@gmail.com".

    By default, all `String` columns in Avram are case sensitive, but if you'd like to use this citext column, just add `case_sensitive: false` to your migrations!

    ```crystal
    # NOTE: You must enable the extension for this feature to work!
    enable_extension "citext"

    create table_for(User) do
      add name : String
      add email : String, case_sensitive: false
    end
    ```

    [Read more](https://github.com/luckyframework/avram/pull/608) on this feature.

    ### Composite Keys

    Speaking of migrations... We're slowly working on adding in "composite-primary keys". This is the concept of having 2 (or more) columns that are combined for primary key
    lookups in your database. Generally you'll just use a single `id` column, but with a composite primary key, you could have "id1" and "id2", and a record is looked up
    using both of those fields.

    For now, we've only enabled this on the migration side. [See the PR](https://github.com/luckyframework/avram/pull/616).

    ### Ditching `route` and `nested_route`

    Lucky comes built with two special macros `route` and `nested_route` which automatically define both the HTTP Verb, and the actual request path for your actions.
    This is nice because `Users::Index` magically becomes `get "/users"`, and `Users::Comments::Index` is turned in to `get "/users/:user_id/comments"`. It cleans
    up your code a little, and makes things consistent.

    Now the downside to this is, what does `Admin::Report::Spending` become? Or how about `Git::Push`? The `route` and `nested_route` macros work great when you're
    building simple REST related resources, but in more complex cases, you end up writing your routes our manually. This means your actions are no longer written consistently.
    Also, newcomers that aren't familiar with what "REST" is may not understand the "magic" that is happening.

    For this reason, we've decided to start deprecating these two. They aren't officially deprecated, so you have plenty of time to still use them, but plan on migrating
    over to hand written routes in your actions.

    Read this [PR](https://github.com/luckyframework/lucky/pull/1378) and this [PR](https://github.com/luckyframework/lucky_cli/pull/594). Also expect the docs related to
    these to be dropped soon.

    ### And much more!

    Here's a few goodies we don't have time to cover:

    * Ability to `pause` running Flow specs
    * Test if an email was sent with `have_delivered_emails` expectation
    * Use `has_one` in your `SaveOperation`
    * Support for `Array(UUID)` column types
    * New `validate_numeric` validation
    * A new Heroku buildpack for (slightly) faster deploys with

    Read through the [CHANGELOG](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md) to see it all!

    ## Parting words

    Each release we make lots of strides towards hitting our goal of a solid 1.0 release. You can help us by building an app!
    Build anything, and let us know your thoughts. What do you like, what would you like to see improved?

    If you find any issues, don't hesitate to [report them](https://github.com/luckyframework/lucky/issues).
    If you're unsure, just hop on [Discord chat](https://discord.gg/HeqJUcb) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [Discord](https://discord.gg/HeqJUcb).
    MD
  end
end
