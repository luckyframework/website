class Lucky029Release < BasePost
  title "Happy Holidays and welcome Lucky 0.29"
  slug "lucky-0_29-release"

  def published_at : Time
    Time.utc(year: 2021, month: 12, day: 8)
  end

  def summary : String
    <<-TEXT
    The Lucky 0.29 release brings us many more
    quality of life updates, bug fixes, and a
    few new features to really make your app
    solid.
    TEXT
  end

  def content : String
    <<-MD
    Lucky 0.29.0 is now out, and a few apps
    in the wild have already upgraded!

    This release mainly focused on quality of life. Lots of bugs have
    been fixed, and many UI/UX updates to round out and polish the overall
    feel of the framework. There are a few new features as well, so let's
    cover some of the highlights.

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-027-to-028).

    Or you can view the changes using [LuckyDiff](https://luckydiff.com/?from=0.28.0&to=0.29.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    ### Squashed bugs

    No software is without its share of bugs, but we've put a big focus on fixing
    many of the rough edges.

    * Lucky no longer writes to the body on HTTP HEAD calls. (oops 😅)
    * The Lucky ecosystem development dependencies (like Ameba) are no longer installed on every app.
    * HTML boolean attributes use valid markup. (e.g. `<input checked />` VS `<input checked="true" />` )
    * The 404 error page no longer returns a 200 response.
    * You can now define a model named `Status`.
    * Migrations are sorted in the correct order when using Breeze.
    * `lucky dev` no longer clashes with Elixir development via the `mix` command.

    ### Improved developer experience

    Lucky tries to focus on the development experience by catching bugs and issues
    while you're developing your application. Here's a few items to make that nicer.

    * Pending migrations will stop your app and show you a more noticable banner.
    * Using attributes in operations will catch many of the common misuses like calling `to_s` instead of `value.to_s`.
    * The file watcher is a lot less greedy. Compilation between file changes goes a bit quicker now.
    * `lucky routes` looks nicer, and provides extra flags to see which params are used in your actions.
    * You don't have to name your asset manifest file `mix-manifest.json`. This makes using other asset bundlers (like Parcel) easier.
    * Lots of additional escape hatches for when you need to get a bit more custom than what Lucky provides.

    ### Lucky cache

    This is a large step forward in our goal to be a solid 1.0 framework.
    A new shard [LuckyCache](https://github.com/luckyframework/lucky_cache/) has been
    created that allows you to add caching at the application level. It's a
    low-level cache you can use to do fragment cache on your pages, or cache specifc
    queries that you need access to, but don't need to on every single request.

    ```crystal
    # example usage
    mobile_ad = LuckyCache.settings.storage.fetch("your_key", expires_in: 24.hours) do
      AppSettingsQuery.new.ad_banner("mobile").first
    end

    iframe(src: mobile_ad.source_url)
    ```

    In addition, we've also added in Query Caching. The query cache can be enabled/disabled
    in your `config/database.cr` by changing the `query_cache_enabled` setting accordingly.

    The query cache mechanism is designed to store your ModelQuery results in to memory
    over the duration of an HTTP request.

    ```crystal
    # this hits the database
    UserQuery.new.first

    # this is pulled from cache in-memory
    UserQuery.new.first
    ```

    ### More with validations

    We've also made some improvements with validations. Each validation method
    now returns a `Bool` value if it succeeded or not.

    ```crystal
    before_save do
      if validate_required(code)
        run_super_complex_validation
      end
    end
    ```

    There's also a new validation method `validate_format_of`. Use this validation
    to test if an attribute meets a specific format.

    ```crystal
    before_save do
      validate_format_of pin, with: /^d+$/
    end
    ```

    As you may know, non-nilable attributes are automatically ran through
    required validations. Since they can't be nil, we need to ensure they
    have a value. To go along with these default validations, we also have
    a new macro called `default_validations`.

    The `default_validations` macro allows you to specify your own custom
    default validations that you need to run. These validations are ran
    after all of the `before_save` blocks have completed allowing you to
    do any necessary setup before hand.

    ```crystal
    before_save do
      code.value ||= "1234"
    end

    default_validations do
      validate_required code
    end
    ```

    In some instances, you may need to just skip all of the default validations
    , including the ones Lucky runs for you. To do this, we've added the `skip_default_validations`
    macro. Place this in the operation you wish to skip those validations.

    ```crystal
    class SaveCode < Code::SaveOperation
      skip_default_validations

      # ...
    end
    ```

    Lastly, the validations are all now compatible with I18n. You have many choices
    for shards that can handle translations for you. Create a struct and inherit from
    `Avram::I18nBackend` to override the defaults.

    ```crystal
    # config/i18n.cr
    struct I18n < Avram::I18nBackend
      def get(key : String | Symbol) : String
        # do your lookup here
      end
    end

    # config/database.cr
    Avram.configure do |settings|
      # ...

      settings.i18n_backend = I18n.new
    end
    ```

    > [Read the PR](https://github.com/luckyframework/avram/pull/757) for more details.

    ## Parting words

    We want to acknowledge and thank the community members for sticking with the Lucky Framework.
    Lucky has set a goal to be a solid and stable choice for a Crystal based web-framework and in
    most cases, we feel we have hit the mark.

    At this point we had hoped to be closer to the 1.0 release, but due to life outside of open source,
    that has been pushed back. The core team wants to be open and transparent about the state of things
    and keep everyone in the loop.

    A [discussion thread](https://github.com/luckyframework/lucky/discussions/1615) has been opened
    with more details on our release schedule. With this release, we're now even closer to our goal.
    If you have any questions, please feel free to reach out any time.

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat,  please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
