class Lucky100Release < BasePost
  title "Announcing the official release of Lucky 1.0.0!"
  slug "lucky-1_0_0-rc1-release"

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
    Congratulations to the Lucky community for coming together and bringing this
    great stable release! We are pleased to announce Lucky is officially 1.0.
    This was a smaller release compared to the RC1, and mainly focused on bug fixes
    and overal stability to ensure going foward, the framework is solid and ready
    to ship out all over the world.

    We will cover a few notable differences, but you can view all the changes
    from the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-100-rc1-to-100).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=1.0.0-rc1&to=1.0.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    This release was one of the smaller ones that we've had in a while. The main
    focus has been bug fixes and stability to ensure the 1.0 release felt solid.

    ### Bug and stability fixes

    We had several contributions from developers that fixed bugs ranging from how
    the Accept headers are handled, to fixes with the SSE Lucky watcher. These
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
    dockerfile will be configured for your setup. If you generate an API only app, the dockerfile
    no longer needs to install NodeJS.

    After generating your new Lucky application, just run `docker compose up`, and Docker will
    take care of the rest for you!

    ### CockroachDB

    If you haven't heard of [CockroachDB](https://www.cockroachlabs.com/product/), yet, now
    is a great time as any! This amazing database uses a PostgreSQL interface allowing you
    to connect as if you're just connecting to Postgres. Since it works just like Postgres,
    this means we can support it natively with Avram.

    This release comes with several fixes for CockroachDB as a few different community members
    are actively using it. We will continue to make things smoother over time, but give it a shot
    and let us know how it goes!

    ## Roadmap

    Roadmaps can be difficult to layout, especially with OSS. Things may change at anytime; however,
    here's a small list of a few things that feel sound when it comes to what to expect next with Lucky.

    ### Native Windows support

    Crystal itself has been gaining more traction in this space over the past few releases. With the
    upcoming (as of this writing) version 1.8.0, there will be a lot more fixes to how well Crystal
    works natively on Windows.

    With this push, we have slowly started ensuring that the entire Lucky ecosystem is available
    to work on Windows natively. You can follow along with in [#1746](https://github.com/luckyframework/lucky/issues/1746).
    If you're currently a developer using Windows, any help you can provide will be greatly beneficial,
    to all of us.

    ### Supporting other DBs

    When we started Lucky, we knew supporting multiple DBs would just be a huge undertaking.
    By only supporting Postgres, we can focus on changes without worry of breaking a different DB engine
    like MySQL, for example.

    This saves us a lot of time, but comes at the cost of alienating users that can't or don't want
    to use Postgres as their database. Thankfully, there are options like CockroachDB that we can
    support with not much extra effort, but if you're looking to use something like MySQL, or even
    a nosql DB like MongoDB, you will need to use an alternate ORM.

    Currently, you have the option to remove Avram as your ORM, and replace it with any ORM that
    supports what you need. In a future version of Lucky, it would be nice if we had a small
    framework that would allow developers to create their own extensions for a tighter integration.

    ### Better complex queries

    Avram works beautifully when constructing queries. You have the typesafety, and abstracting
    parts of your query in to simple methods is a breeze. This starts to fail the second you
    need anything slightly custom. For example, returning only some columns of a row, or doing
    aggregate queries, or the ever famous CTE queries.

    For these, you have the option to drop down to raw SQL. We would love to make the barrier
    between a high level query object, and low level raw SQL reduced. Adding a better interface
    for complex queries, and interoperability between a Query object and Array of results will
    help developers to scale out their applications to larger and more complex apps while keeping
    all of the safety Lucky provides.

    ### Asset Management

    One of the best features of Lucky is that your application comes with typesafe asset
    management, as well as a build tool out of the box. This means that you can ensure
    that an image loaded on your site is guaranteed to be there in production. You have
    the ability to use Vue, or React right away.

    Currently Lucky ships with [LaravelMix](https://laravel-mix.com/). This tool was
    the default setup for the Laravel PHP Framework, until they announced that
    [Vite is now the default](https://laravel-news.com/vite-is-the-default-frontend-asset-bundler-for-laravel-applications).
    [ViteJS](https://vitejs.dev/) is a great tool, and Lucky actually has support for this
    out of the box as well, but the question now is.... what should the default be?

    We would like to put some time into keeping our typesafe system for assets, but also
    make swapping out build tools a lot easier. Lucky will always ship with some default,
    but it shouldn't take you an entire day to swap it for something else.

    ### Updated CLI UI/UX

    One of the most requested features for the CLI is the ability to generate a default
    application without a DB. This makes sense as the website itself is a Lucky app
    without a DB. Doing this will also be a step towards supporting alternate ORMs.

    Maybe we can even make this CLI interface look really nice with a fancy UI!

    ## Parting words

    We're so grateful to the community for all of the help and support in getting to this
    1.0 release. Lucky has been used in production for several years now, and has proven
    that businesses can use it as their main stack. Now with Lucky reaching the 1.0 milestone,
    we are excited to see where things go for 2.0!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
