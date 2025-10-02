class Lucky100Release < BasePost
  title "Announcing the official release of Lucky 1.0.0!"
  slug "lucky-1_0_0-release"

  def published_at : Time
    Time.utc(year: 2023, month: 3, day: 14)
  end

  def summary : String
    <<-TEXT
    We're excited to finally announce the official release
    of Lucky 1.0.0! Read more on what this release brings,
    and a roadmap for what is to come in the future.
    TEXT
  end

  def content : String
    <<-MD
    We are pleased to announce Lucky is officially 1.0! After a successful RC1
    that helped us polish a handful of bugs, the framework is solid, and ready
    to start planning for the next major 2.0 release in the future. This could
    not have been done without all of the support and effort from community
    members that contributed along the way.

    We will cover a few notable differences, but you can view all the changes
    from the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-100-rc1-to-100).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=1.0.0-rc1&to=1.0.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    This release is smaller compared to our regular releases. The main
    focus has been bug fixes and stability to ensure the 1.0 release felt solid.

    ### Bug and stability fixes

    We had several contributions from developers that fixed bugs ranging from how
    the Accept headers are handled, to fixes with the server-sent events (SSE) Lucky watcher. These
    fixes help polish the edges of the framework for many edge cases that appear as
    your app starts to grow.

    A few other notable fixes are
    * Saving records with JSON values that contain `null` now save properly
    * Some HTML tags have a block variant. You can now create your own custom wrapper that takes a block
    * Association preloads don't reload already loaded associations, as well as a compilation issue when preloading optional associations
    * Submitting a form with only a file now properly saves
    * More fixes to how Arrays are handled within params

    If you happen to find any bugs, please let us know!

    ### Docker setup

    New Lucky apps ship with a default Docker setup allowing you to boot your app
    for local development in Docker. This setup has been in a few versions, but until
    this release, it's required some manual configurations to work.

    We spent some time on this setup. Now when you generate a new Lucky app, the generated
    Dockerfile will be configured for your setup. If you generate an API only app, the Dockerfile
    no longer needs to install NodeJS.

    After generating your new Lucky application, just run `docker compose up`, and Docker will
    take care of the rest for you!

    ### CockroachDB

    If you haven't heard of [CockroachDB](https://www.cockroachlabs.com/product/), it's "A distributed SQL database designed for speed, scale, and survival". This amazing database uses a PostgreSQL interface allowing you
    to connect as if you're just connecting to Postgres. Since it works just like Postgres,
    this means we can support it natively with Avram.

    This release comes with several fixes for CockroachDB as a few different community members
    are actively using it. We will continue to make things smoother over time, but give it a shot
    and let us know how it goes!

    ## Roadmap

    Roadmaps can be difficult to layout, especially with open-source software. Things may change at anytime; however,
    here's a small taste of what to expect next with Lucky:

    ### Native Windows support

    We have slowly started ensuring that the entire Lucky ecosystem is available
    to work on Windows natively. You can follow along with in [Issue #1746](https://github.com/luckyframework/lucky/issues/1746).
    If you're a developer using Windows, we'd love to hear from you.

    ### Supporting other ORMs

    For better support with other ORMs that allow you to choose alternate DBs, we'd love to
    have a better interface for shard extensions with ORMs. Our goal is to support all of the form helper
    methods, file uploads, and features Avram gives you within Lucky, in an ORM-agnostic way.

    ### Better complex queries

    Building more complex queries with Avram allowing you to use better casting, common table expressions, dynamic
    functions and more. This would become a happy medium place between using Lucky's query objects and
    dropping down to raw SQL.

    ### Asset Management

    We would like to put some time into keeping our type-safe system for assets, but also
    make swapping out build tools a lot easier. Lucky will always ship with a reasonable default,
    but it shouldn't take you an entire day to swap it for something else.

    ### Updated CLI UI/UX

    One of the most requested features for the CLI is the ability to generate a default
    application without a DB. This makes sense as our main Lucky website (the one you're reading now) is a Lucky app
    without a DB. Doing this will also be a step towards supporting alternate ORMs.

    We're also excited to try out some fancy, command line UI design!

    ## Parting words

    We're so grateful to the community for all of the help and support in getting to this
    1.0 release. Lucky has been used in production for several years now, and has proven
    that businesses can use it as their main stack. Now with Lucky reaching the 1.0 milestone,
    we are excited to see where things go for 2.0!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Bluesky](https://bsky.app/profile/luckyframework.org/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
