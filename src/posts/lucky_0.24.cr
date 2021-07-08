class Lucky024Release < BasePost
  title "Lucky v0.24 is out, and it's another step closer to 1.0!"
  slug "lucky-0_24-release"

  def published_at : Time
    Time.utc(year: 2020, month: 9, day: 8)
  end

  def summary : String
    <<-TEXT
    Lucky v0.24 is out. A few new features, bug fixes,
    improved performance, and more!
    TEXT
  end

  def content : String
    <<-MD
    [Lucky v0.24](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-024)
    is out now and updated to work with Crystal v0.35.1

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-023-to-024).

    Or you can view the changes using [LuckyDiff](https://luckydiff.com/?from=0.23.0&to=0.24.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    ### `m` is now `mount` (again)

    Ok, so sometimes you get a great idea, and try it out, and then later realize maybe it wasn't the best 😅.
    When we changed `mount` to be `m`, we also changed the signature which paves the way for some pretty neat
    future updates we have planned.

    We realized that `m` is hard to search for, and it's a little confusing to newcomers, so we've reverted the
    name back to `mount`; however, we kept the same signature.

    ```crystal
    # in Lucky 0.23
    m Shared::Footer, year: 2020

    # in Lucky 0.24
    mount Shared::Footer, year: 2020
    ```

    A simple rename, and you're good to go!

    ### New `data` method

    Your Action classes will always return some response whether it's `json()` for your API,
    or `html()` for your browser apps. Now we have `data()` which can be used for responding with
    the contents of a file or other data.

    > For anyone familiar with using Ruby on Rails, this is similar to the Rails
    `send_data` method.

    ```crystal
    class Reports::Show < BrowserAction

      get "/reports/:id" do
        info = gather_data(id)

        data(info, disposition: "inline")
      end
    end
    ```

    [View the PR](https://github.com/luckyframework/lucky/pull/1220) for more context.

    ### Disallow external refs in `redirect_back`

    In Lucky 0.23.0 we added the `redirect_back` method to redirect a user back to the referer or a specified
    fallback path. In this version, we've disallowed redirecting back to external hosts unless you specify.

    ```crystal
    redirect_back fallback: Home::Index, allow_external: true
    ```

    [Read more on the PR](https://github.com/luckyframework/lucky/pull/1241)

    ### Renamed `PostgresURL` to `Credentials`

    When configuring your database in `config/database.cr`, you would set your URL string, or
    pass a few options to `PostgresURL`. We've renamed this to `Avram::Credentials` which allows us
    to validate your connection string at compile time.

    Before this release, you could have this:

    ```crystal
    # in config/database.cr
    settings.url = Avram::PostgresURL.build(
      #...
      username: `whoami`
    )
    ```

    Doing this would cause your username to be set as `"myuser\n"` which could lead to some issues.
    Now we can catch that, and have a better structure for adding future validations as other edge cases arise.

    ```crystal
    # in config/database.cr
    settings.credentials = Avram::Credentials.new(
      #...
      username: "myuser"
    )
    ```

    Along with the better safety, we also now have a standard for apps to use that don't need to connect to a database.
    (Like this website).

    ```crystal
    # in config/database.cr
    settings.credentials = Avram::Credentials.void
    ```

    [Read more on the PR](https://github.com/luckyframework/avram/pull/433)

    ### Box `build_attributes`

    When you're writing your tests, you'll use Boxes as factories for your models. In this release,
    we've added in a method to return a `NamedTuple` of the attributes without creating a new record.

    ```crystal
    class AdminBox < BaseBox
      def initialize
        name "Admin"
      end
    end

    admin_attrs = AdminBox.build_attributes

    admin_attrs[:name] == "Admin"
    ```

    [Read more on the PR](https://github.com/luckyframework/avram/pull/449)

    ### Moving from Gitter to Discord

    Starting with this release, we've decided to move our community forum over to Discord. This
    was by no means a quick decision, and has been in the works with the core team for quite some time.
    To clarify a few of our reasons for choosing an alternate platform:

    * Better mobile support - We find ourselves AFK often, but still want to help when help is needed, even on the go.
    * Better emoji/reaction/giph supprt - This may seem silly, but when chatting online, it's hard to gauge emotion.
      This can change how a community is percieved by a simple thumbs up or funny gif.
    * Better syntax highlighting - Discord allows you to use GFM and specify your language in code blocks. Neat!
    * Better searching - Finding comments from past conversations was pretty common, and needed to be easier
      so we could go back to reference.
    * Plus all of the other things we looked for - easy onboarding, free, not self-hosted, widely used / well supported
      and not buggy

    We understand this is a big change, so please bear with us while we give this a test.

    ## Parting words

    There's plenty more updates in this release, so go and try them out! we appreciate all the support
    everyone has shown helping to make each release better and better. We're really excited about getting closer to a 1.0 release!

    Please give it a spin and help us find bugs so our next release is even more solid.
    If you find any issues, don't hesitate to [report the issue](https://github.com/luckyframework/lucky/issues).
    If you're unsure, just hop on [Discord chat](#{Chat::Index.path}) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [Discord](#{Chat::Index.path}).
    MD
  end
end
