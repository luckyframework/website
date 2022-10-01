class Lucky100rc1Release < BasePost
  title "Lucky begins the 1.0 ascent with the first release candidate"
  slug "lucky-1_0_0-rc1-release"

  def published_at : Time
    Time.utc(year: 2022, month: 10, day: 1)
  end

  def summary : String
    <<-TEXT
    Lucky 1.0.0-rc1 has been released, and it's a huge milestone
    for the framework and community.
    TEXT
  end

  def content : String
    <<-MD
    As many developers know, reaching a 1.0 milestone is huge, and something to
    be celebrated. We're excited to publish the first release candidate of Lucky 1.0.
    We will be using this and the next few release candidates to clean up
    the rough edges of the framework, and make sure all of the dependencies in the
    Lucky ecosystem are solid and ready to take us to the next level.

    We will cover a few notable differences, but you can view all the changes
    from the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-030-to-100-rc1).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=0.30.0&to=1.0.0-rc1).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    This version releases several breaking changes that were needed in
    order to make the framework more extensible for the future.

    ### No more DB dependency

    Many sites (including this one) have no need for a databaase. In some cases,
    your data comes from a 3rd party API, or maybe you need a custom database
    engine other than PostgreSQL.

    In this release, Avram is no longer a dependency of Lucky, but instead,
    Lucky is now an optional dependency of Avram. If you're using Avram outside
    of Lucky, then nothing changes for you. However, for existing Lucky users upgrading to `rc1` that need Avram,
    you'll now have to include it as an additional dependency. Be sure to add it
    to your `shard.yml` file, and require it in your `src/shards.cr`.

    ### Support for Array params in operations

    Support for Arrays in Lucky and Avram have existed for a few versions now.
    This includes support for arrays in params. However, one bit that has been
    missing was the ability to pass those array params through to an operation.

    For example:

    ```crystal
    # before this release
    # post:tags[]=lucky&post:tags[]=crystal
    tags = params.nested_arrays("post")["tags"]
    SavePost.create(params, tags: tags) do |operation, post|
      # ...
    end

    # after this release
    SavePost.create(params) do |operation, post|
      # ...
    end
    ```

    This ended up being quite a big breaking change. The original Params implementation
    assumed the type was `Hash(String, String)`, but this meant you couldn't have an
    array value. Now the type assumes `Hash(String, Array(String))` which is actually
    the same type as [`URI::Params`](https://crystal-lang.org/api/1.5.1/URI/Params.html#new%28raw_params%3AHash%28String%2CArray%28String%29%29%29-class-method).

    ### Changes to the javascript Ecosystem

    As we all know, the javascript ecosystem changes in leaps and bounds daily.
    This makes it very difficult to keep up.

    In 2017, when Lucky began, the Rails core team had a neat library called
    [Turbolinks](https://github.com/turbolinks/turbolinks-classic).
    This library helped to make pages feel even faster, and who doesn't love speed?
    Lucky included this library by default, but Rails has since deprecated Turbolinks in favor
    of [Turbo](https://turbo.hotwired.dev/). Although Lucky doesn't include Turbo yet,
    we would still like to encourage users to give it a shot, and let us know if this
    is something you'd like to see included by default.

    Along those same lines, Lucky also came out-of-the-box with [Laravel-Mix](https://laravel-mix.com/)
    which is "An elegant wrapper around Webpack". This made bringing javascript to Lucky
    seamless, and easy. However, the Laravel framework has [moved to Vite](https://laravel-news.com/vite-is-the-default-frontend-asset-bundler-for-laravel-applications)
    as their default front-end. Laravel-Mix may or may not stick around, but with the
    uncertainty, the 1.0.0-rc1 release opens up the possibility to use [Vite](https://vitejs.dev/)
    while keeping with the type-safe traditions Lucky brings.

    If you'd like to experiment with it, updated your `src/app.cr`, with this code

    ```crystal
    # src/app.cr
    Lucky::AssetHelpers.load_manifest "public/manifest.json", use_vite: true
    ```

    Then you'll just need to setup Vite as your build system. For some examples,
    you can visit this [Vite Lucky test app](https://github.com/jwoertink/vite_lucky)

    So why even include a javascript build system with Lucky?

    One of Lucky's goals is to be type-safe and help catch bugs in development. This
    is done in many ways, but one of the most important ways is when it comes to loading
    your assets in production. By utilizing a generated manifest file, Lucky can
    generate an internal `NamedTuple` at compile-time that can be referenced in the app.
    When you forget to add an asset (i.e. image, style, script, etc...), a compile-time
    error will raise letting you know.

    ### Email layouts and callbacks

    Carbon 0.3.0 has been released with a few neat updates. The first being
    the ability to set email layouts. Just like your standard views, you may
    have a very similar wrapper on your emails like contact footer info, or
    your logo.

    To specify your layout, you'll add the `layout` macro, and pass the name
    of the folder where your layout template file is located.

    ```crystal
    # src/emails/welcome_email.cr
    class WelcomeEmail < BaseEmail
      def initialize(@recipient : Carbon::Emailable)
      end

      to @recipient
      from "info@myapp.com"
      subject "Welcome to the site!"
      layout my_email_layout
      templates html, text
    end
    ```

    Then in your templates, you can add `my_email_layout/layout.ecr`,
    and use the `content` method to yield your email body

    ```
    # src/emails/templates/my_email_layout/layout.ecr
    <h1>Our Email</h1>

    <%= content %>

    <div>footer</div>

    # src/emails/templates/welcome_email/html.ecr
    <p>Welcome to the site!</p>
    ```

    Emailing can be tricky. Sometimes it's hard to track emails,
    and other times you're dealing with unsubscribes. To help with
    these, we've added `before_send` and `after_send` callbacks,
    as well as a `deliverable : Bool` property. When `deliverable`
    is set to `false`, the email won't be sent.

    ```crystal
    class FriendIsLiveEmail < BaseEmail
      def initialize(@recipient : Carbon::Emailable, @friend : User)
      end

      before_send do
        if !@recipient.wants_email_from_friend?(@friend)
          self.deliverable = false
        end
      end

      # the response is from the email service (i.e. sendgrid, etc...)
      after_send do |response|
         MarkEmailAsRecentlySent.run(self, sent_at: Time.utc)
      end
    end
    ```

    ### More ORM updates

    Working towards better compatibility with [CockroachDB](https://www.cockroachlabs.com/product/)
    enums now support both `Int64` values, as well as the `@[Flags]` annotations making bitwise
    permissions super easy to achieve in Lucky!

    Another amazing update is the addition of the `extract()` query method for timestamp columns.
    This allows you to query for date parts of a `Time` object. For example, query for
    all users that signed up in July.

    ```crystal
    UserQuery.new.created_at.extract(:month).eq(7)
    ```

    This `extract` method accepts any of the following chronounits:

    ```crystal
    enum ChronoUnits
      Century
      Day
      Decade
      Dow
      Doy
      Epoch
      Hour
      Isodow
      Isoyear
      Julian
      Microseconds
      Millennium
      Milliseconds
      Minute
      Month
      Quarter
      Second
      Timezone
      TimezoneHour
      TimezoneMinute
      Week
      Year
    end
    ```

    We've also added support for the `bytea` column with Crystal's `Byte` (`Slice(UInt8)`) alias.

    ```crystal
    # In your model
    table do
      column data : Byte
    end
    ```

    ## Parting words

    Thank you to everyone that helped with this release, and welcome to
    all of the new people that have joined our Discord recently. It's
    fun and exciting seeing all of the growth happening.

    Please report any issues, and as always, PRs are greatly appreciated!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
