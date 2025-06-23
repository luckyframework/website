class Lucky141Release < BasePost
  title "Lucky v1.4.1 has been released"
  slug "lucky-1_4_1-release"

  def published_at : Time
    Time.utc(year: 2025, month: 6, day: 20)
  end

  def summary : String
    <<-TEXT
    v1.4.1 is out now, and full Windows support is right around the corner.
    TEXT
  end

  def content : String
    <<-MD
    Lucky v1.4.1 has been released. This release focused on a few bugs and compatibility with Crystal up to v1.16.3

    Read through the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)
    for all of the changes and read below for a few highlights.

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-130-to-140).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=1.3.0&to=1.4.1).

    ## Here's what's new

    ### Rate Limiting

    Lucky Actions now have a "Rate Limiting" feature that allows you to limit the number of calls to an action within
    a specified period. To use this feature, you will just need to include the new `Lucky::RateLimit` module.

    ```crystal
    class Users::LivePingCheck < ApiAction
      include Lucky::RateLimit

      rate_limit to: 1, within: 1.minute

      get "/users/live_ping_check" do
        plain_text "ok"
      end

      private def rate_limit_identifier : String
        "live-ping-check"
      end
    end
    ```

    This will limit the number of requests to the endpoint to a max of 1 every 1 minute. It will use the
    `rate_limit_identifier` key for the lookup which you can customize if you need to set the limit to different amounts
    on a per user basis, for example.

    ### No more bash script setups

    In order for us to better support Windows, we needed to remove the bash scripts that were used for bootstrapping a
    Lucky application. While using Powershell would have been an option, this also would have made the code in the LuckyCLI
    much more difficult to maintain due to having different codebase structures for Windows and non-Windows.

    Instead, we decided to just port all of the scripts straight to Crystal. This is now a lot more cross-platform compatible
    since you will need Crystal on any machine you're using anyway. You can now generate a new Lucky app on Windows, and
    bootstrap the app with `crystal script/setup.cr`.

    ### Separate Read/Write databases

    Avram now supports using separate read and write databases for queries. By default, this will continue to use your
    single specified database.

    ```crystal
    abstract class BaseModel < Avram::Model
      def self.read_database : Avram::Database.class
        ReaderDB
      end

      def self.write_database : Avram::Database.class
        WriterDB
      end
    end

    # Uses the ReaderDB
    user = UserQuery.find(1)

    # Uses the WriterDB
    SaveUser.update!(user, last_active_at: Time.utc)
    ```

    Currently this will only change the connection between doing queries and saving records through Save or Delete operations.
    Handling tasks such as fallbacks, or retries based on latency from reading and writing are not supported.

    ### Table Locking

    Table locks control which actions can be performed on a table at the same time. Postgres has
    [eight different table locking modes](https://www.postgresql.org/docs/current/explicit-locking.html#LOCKING-TABLES) that
    allow you to specify the locking behavior. Avram now supports all eight.

    The `AppDatabase.with_lock_on` method takes the model whose table you will be locking, and the locking `mode`.
    Then within the block, the lock is applied and all queries made will happen within a transaction.

    ```crystal
    AppDatabase.with_lock_on(User, mode: :row_exclusive) do
      user = UserQuery.new.id(1).for_update.first
      SaveUser.update!(user, name: "New Name")
    end
    ```

    These are the eight modes:

    ```
    ACCESS_SHARE
    ROW_SHARE
    ROW_EXCLUSIVE
    SHARE_UPDATE_EXCLUSIVE
    SHARE
    SHARE_ROW_EXCLUSIVE
    EXCLUSIVE
    ACCESS_EXCLUSIVE
    ```

    ### Type-safe ENV methods

    LuckyEnv got a few updates as well. When you use LuckyEnv, it will generate methods for each of your
    environment variables and automatically type-cast them depending on the value. The supported types are
    `String`, `Bool`, `Int32`, and `Float64`.

    ```
    CACHE_ENABLED=true
    PORT=3000
    HOST="localhost"
    EXCHANGE_RATE=3.14
    ```

    With this `.env` file loaded in, you now have access to these methods:

    ```crystal
    LuckyEnv.cache_enabled? #=> true
    LuckyEnv.port #=> 3000
    LuckyEnv.host #=> "localhost"
    LuckyEnv.exchange_rate #=> 3.14
    ```

    ### State of LuckyFlow

    If you're not familiar, LuckyFlow is a shard that ships with new browser based Lucky apps that
    helps with doing Acceptance testing by spinning up a browser and walking through a user's flow
    using your site.

    We released LuckyFlow v1.4.1 and skipped v1.4.0. This was due to some bugs we found in LuckyFlow
    that were causing specs to fail randomly on new generated apps. These failures are new and seem to be
    race conditions that we have yet to find.

    Due to the complexity of LuckyFlow needing several dependencies, like Selenium, and handling several
    different webdrivers (e.g chromedriver, geckodriver, etc...), keeping LuckyFlow updated has become
    quite complex. On top of this, needing to support these drivers across different platforms is also
    very complex.

    For the time being, generating a new Lucky app will still ship with LuckyFlow, but the specs will be
    set to "pending" until we can release a new version with the issues fixed. You are still free to use
    LuckyFlow, but just keep in mind that your specs may randomly fail, and the failure may be unrelated
    to your code.

    > Follow along with the discussion on [Github](https://github.com/luckyframework/lucky_cli/issues/890)

    ## Parting words

    The Lucky community is what makes this framework great. We appreciate all of the new users, and everyone that
    has been contributing to push the framework forward. If you're using Lucky in production, and would like
    to add your application to our [Awesome Lucky](https://luckyframework.org/awesome) "built-with"
    section, feel free to open an issue on the [Website](https://github.com/luckyframework/website/issues)
    or a PR!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [X](https://x.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
