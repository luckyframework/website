class Lucky030Release < BasePost
  title "Small updates with a huge step forward"
  slug "lucky-0_30-release"

  def published_at : Time
    Time.utc(year: 2022, month: 4, day: 11)
  end

  def summary : String
    <<-TEXT
    Lucky 0.30 is one of our smaller releases, but it
    takes a huge step forward with the inclusion of automated security testing.
    TEXT
  end

  def content : String
    <<-MD
    Lucky 0.30 is a smaller release compared to previous ones, but it
    includes some big steps forward. Better error messages, some spring
    cleaning, a few added methods, and the new inclusion of automated security
    testing that we're super excited about!

    We will cover a few notable differences, but you can view all the changes
    from the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-029-to-030).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=0.29.0&to=0.30.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    ### Bright Security (formerly Neuralegion)

    During this release, we've worked directly with the [Bright Security](https://brightsec.com/)
    team to bring out-of-the-box security testing support for Lucky apps!

    When we say "security testing", what we mean is catching vulnerabilities such as:

    * insecure cookies
    * cross-site scripting
    * SQL injection
    * header tampering
    * and more...

    Bright has an API that allows you to scan your application for different vulnerabilities
    using their [SecTester](https://github.com/NeuraLegion/sec_tester) shard. By signing up
    for an API key, you can test specific pages of your application with CI which will help
    prevent pushing broken code to production.

    We have created a thin wrapper ([LuckySecTester](https://github.com/luckyframework/lucky_sec_tester))
    which makes writing some of these tests with your Lucky application a little easier. For now,
    this feature is opt-in when generating a new Lucky app, but it can be added to any existing app
    fairly easily.

    To generate a new app with the SecTester, just run `lucky init.custom your_app_name --with-sec-test`.
    This will generate a new application with the LuckySecTester setup and ready to go, along with several
    specs already written against the existing code. This will help to serve as a template for what you
    can add. This will also generate a Github CI already setup to run with Bright!

    Due to the time it takes to run these specs, we've placed the security specs in their own spec
    file, and behind a compile-time flag `crystal spec -Dwith_sec_tests`. This gives you the option to
    run them only when you really need them. (e.g. during CI).

    Following the Lucky mantra of catching bugs in development, it is our hope that this new integration
    gives you peace of mind that your production app is a lot safer and solid.

    ### Faster specs

    After quite a bit of refactoring, we now have our database related specs running in a transaction
    as opposed to truncating between specs. This has shown to give at least 4x speed to your specs.

    ```crystal
    # notes on how to use this
    ```

    [Read more on this PR](https://github.com/luckyframework/avram/pull/780)

    ### Built-in Process runner Nox

    [Nox](https://github.com/matthewmcgarvey/nox) is a process runner built by [@matthewmcgarvey](https://github.com/matthewmcgarvey).
    Lucky now ships with this out of the box so there's no longer a need to install an additional tool for local development. After
    installing LuckyCLI, you can boot your app locally using `lucky dev`, and this will start the Nox process manager using
    your `Procfile.dev`.

    You can continue to use other process managers such as Overmind, Foreman, or the Heroku CLI if you wish.

    ### MessageVerifier revamped (again)

    The Lucky `MessageVerifier` is a class that allows you to securely pass data around by
    turning that data in to an encrypted string that can later be decrypted. One common use
    for this would be a reset password token.

    The original implementation for this created two tokens, and joined them by a `--`.
    This worked fine until one day the right-side token actually contained `--` as part of
    the encrypted string. Oops! In [#1596](https://github.com/luckyframework/lucky/pull/1596), this
    bug was fixed with the assumption that this edge case only happens on the right side. Oops again!
    As it turns out, this edge case could happen on either the left or right side meaning that
    calling `split("--")` would never guarantee that you'd end up with the two proper strings.

    We've decided to just ditch the magic `--` character, and go a little more generic with a
    Base64 JSON string. The old way will now be deprecated, and removed in the next release.

    [Read more on this PR](https://github.com/luckyframework/lucky/pull/1674)

    ### Remote IPs from the client

    It's pretty common that you may need to get the client's IP. Maybe you need to log it for analytics,
    or maybe you want to do a little geocoding on their
    location. Whatever the reason, it's a nice thing to be able to easily access.

    Crystal's `HTTP::Request` class has the `remote_address` property that we can assign
    this value to, but it returns `Socket::Address | Nil` which made it a bit clunky to access.
    In order to get the IP value as a String, you would have to use this:

    ```crystal
    context.request.remote_address.as?(Socket::IPAddress).try(&.address)
    ```

    In this release, we've made it a little easier by patching `HTTP::Request` with a
    `remote_ip : String?` property. Now you can just do this:

    ```crystal
    context.request.remote_ip
    ```

    While working on this, there was a really facinating blog post that came out discussing
    [The perils of the "real" client IP](https://adam-p.ca/blog/2022/03/x-forwarded-for/). If
    you haven't seen this post, it is highly recommended you read it.

    The first thing it mentions is when using the `X-Forwarded-For` header, you should use
    the "rightmost" IP in the list. Prior to 0.30, Lucky used the "leftmost". We also understand
    that depending on your production setup, you may be behind several load balances, or VPN
    traffic and such. Instead of always relying on the `X-Forwarded-For` header, you now have
    the option to customize *which* header you want to pull this value from.

    ```crystal
    # config/server.cr
    Lucky::RemoteIpHandler.configure do |settings|
      # optionally use the X-Real-IP header instead
      settings.ip_header_name = "X-Real-Ip"
    end
    ```

    ### Slugify Integration

    When you want to use slugs for your URLs in place of passing an ID, you can turn
    to Avram to "slugify" a value for you. Previously we had the `AvramSlugify` shard
    that you would include in your project. We've now integrated this shard directly in
    to Avram itself as `Avram::Slugify`. This will make maintaining and releasing updates
    a lot easier.

    To upgrade, just remove the `slugify` shard from your shard.yml, and rename any use of
    `AvramSlugify` to `Avram::Slugify`. Finally, update the require from `require "avram_slugify"`
    to `require "avram/slugify"`.

    ### Docker default

    As requested for quite a while now, and thanks to community member [@robacarp](https://github.com/robacarp),
    Docker is now shipped with newly generated Lucky apps as a new means for development.

    To get started, it's as simple as generating a new Lucky app, and running `docker compose up`.

    > It will download images, create the database, install npm modules, install shard dependencies, and even migrate the database (just on the first boot).

    ## Parting words

    This release originally planned to have quite a bit more, but due to some time constraints, we
    decided to release with what we had. It also means that our original timeline for release 1.0.0
    has been pushed back a bit more. We will do our best to keep the community up-to-date with the
    release schedule.

    Please report any issues, and as always, PRs are greatly appreciated!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
