class Lucky018Release < BasePost
  title "Lucky 0.18 is out now."
  slug "lucky-0_18-release"

  def published_at : Time
    Time.utc(year: 2019, month: 10, day: 7)
  end

  def summary : String
    <<-TEXT
    Lucky v0.18 introduces many improvements to building JSON APIs. Better serialization,
    built-in JWT auth, and improved error handling.
    TEXT
  end

  def content : String
    <<-MD
    Lucky v0.18 is now out and requires the newest version of Crystal (v0.31.1)

    Be sure to upgrade your version of Crystal, and take a look at our
    [UPGRADE NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-017-to-018)
    for help with migrating your app.

    ## What's new?

    We've made a ton of changes for this release, but we will highlight a few.
    You can see a full list through our [CHANGELOG](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-018).

    ### Built in JWT (JSON Web Token) authentication

    When generating a new app with `lucky init` you will be asked if you want
    Lucky to include authentication. If you choose "yes" Lucky will now include
    code for signing up users, and creating a token that can be used to authenticate
    users with your API.

    Read more about it in the [API Authentication guide](#{Guides::Authentication::Api.path}).

    ### Improved serializers

    Before Lucky 0.18.0 we recommended creating two serializers for each resource.
    One for rendering a single item, and another for rendering a collection. This led
    to a lot of files and code doing the same thing. Now Lucky generates a `BaseSerializer`
    that includes a `for_collection` method.

    That means you only need one class:

    ```crystal
    class UserSerializer < BaseSerializer
      def initialize(@user : User)
      end

      def render
        {id: @user.id, name: @user.name}
      end
    end
    ```

    And it can render one User or a collection of Users:

    ```crystal
    # Serialize one user
    UserSerializer.new(UserQuery.first)

    # Serialize a collection of users
    UserSerializer.for_collection(UserQuery.new)
    ```

    Learn more in the [JSON rendering guide](#{Guides::JsonAndApis::RenderingJson.path(anchor: Guides::JsonAndApis::RenderingJson::ANCHOR_SERIALIZERS)})

    ### Added `between` to queries

    Added a new `between` criteria method to making querying easier:

    ```crystal
    UserQuery.new.created_at.between(30.days.ago, Time.utc)
    ```

    ### Improved error handling

    Previously error handling had lots of conditional logic that made it hard to
    tell what was happening. Now many errors are handled automatically, and
    it is easier to change how an error is rendered to a user.

    For example if you wanted to customize how `MyCustomError` was rendered:

    ```crystal
    class Errors::Show < Lucky::ErrorAction
      def render(error : MyCustomError)
        error_json "This is a custom error message", status: 418
      end
    end
    ```

    More in the [error handling guide](#{Guides::HttpAndRouting::ErrorHandling.path})

    ### Error reporting

    We've also introduced a way to easily report errors. Lucky generates
    an `Errors::Show` class with a new `report` method that is empty. You can
    fill in the method to report it however you want.

    For example, we could use the [Raven shard](https://github.com/sija/raven.cr)
    to send an error report to [Sentry](https://sentry.io/):

    ```crystal
    # src/actions/errors/show.cr
    def report(error : Exception)
      Raven.capture(error)
    end
    ```

    Read more about [error reporting](#{Guides::HttpAndRouting::ErrorHandling.path(anchor: Guides::HttpAndRouting::ErrorHandling::ANCHOR_REPORTING)}).

    ### Keep your database and schema in sync

    We've added a new feature called Schema Enforcer that runs when your server
    is started and in development or test mode. **If you have a missing
    column, table, or incorrect type, Lucky will let you know.**

    For example if we wanted to use a `slug` column in the `Post` model but we
    forgot to add it:

    ```bash
    Post wants to use the column 'slug' but it does not exist.

    Try adding the column to the table...

      ▸ Generate a migration:

          lucky gen.migration AddSlugToPosts

      ▸ Add the column to the migration:

          alter :posts do
            add slug : String
          end

    ```

    ## Parting words

    We're very excited about this release, and hope you are too. Please give it a spin and help
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
