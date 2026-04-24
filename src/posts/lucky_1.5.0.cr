class Lucky150Release < BasePost
  title "Lucky v1.5.0: A modern frontend toolchain, and a lot more"
  slug "lucky-1_5_0-release"

  def published_at : Time
    Time.utc(year: 2026, month: 4, day: 28)
  end

  def summary : String
    <<-TEXT
    The biggest change in 1.5.0 is the asset pipeline: the old Yarn + Laravel Mix setup is deprecated in favor of a single Bun install that's
    faster, simpler, and drops NodeJS entirely. Lots of new features like table partitioning, a new Redis extension for LuckyCache,
    per-action request body limits, security fixes, and more!
    TEXT
  end

  def content : String
    <<-MD
    Lucky v1.5.0 is out, and it's packed. The biggest change is a brand new asset pipeline built on top of Bun, replacing the Yarn and
    Laravel Mix setup we've shipped with since day one. Along with that, there's a lot of exciting features and fixes to cover.

    Read through the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)
    for all of the changes and read below for a few highlights.

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-140-to-150).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=1.4.0&to=1.5.0).

    ## Here's what's new

    ### Bun

    This is a massive change to the framework. Since the beginning, Lucky has shipped using `Yarn` with `Laravel Mix`
    as the default asset manager and builder system. Back in 2017 this was a widely used workflow. But as many already
    know, the Javascript ecosystem moves faster than anyone can keep up with. By 2026, we had so many options to choose
    from that were easier to configure, and faster at building, it was difficult to decide which to use.

    We originally wanted to build a pluggable system to allow you to decide which system you wanted, but that added
    so much extra complexity, and had the added downside of extra levels of testing and support. That option may be
    something we look at again in the future, but for now we wanted something we can easily support.

    [Bun](https://bun.sh/) was chosen because of its speed and simplicity. By using Bun, we no longer have a dependency
    on NodeJS, Yarn, or LaravelMix/Vite. It's a single install that gives us full flexibility to use TypeScript, modern CSS,
    and still keep our Type-Safe asset handling with no additional plug-ins or dependencies. Assets now build in a fraction
    of the time, automatic browser reloading happens magically, and cache-buster fingerprints on production
    assets (including images, fonts, and more) all exist without the need for extra configuration.

    This is just the start, but if there's anything missing, take a look at the [Lucky.js](https://github.com/luckyframework/lucky/blob/d498d4d2d4d7a77e83a7a103cd4338ea6caa6ca6/src/bun/lucky.js#L6)
    and open an issue to discuss.

    ### Infrastructure

    The release system has been fixed again allowing us to release 1.5.0 to Scoop on Windows. With each release of
    Crystal and Lucky, native Windows support is getting better. Lucky is already fully usable on Windows, but in
    some cases, it can take a little extra work. The latest release moves us closer to a smooth out-of-the-box experience.

    ### Cookie update

    A bug was discovered in how cookies were being encrypted where there was a small chance a cookie could be
    susceptible to being decrypted by a 3rd party. This bug was fixed; however, it is considered a breaking change.
    Any cookie that was encrypted before Lucky 1.5.0 will fail to decrypt. To solve this, you will just need
    your users to generate new cookies.

    [Read more in the PR](https://github.com/luckyframework/lucky/pull/2026)

    ### Table partitioning

    [@russ](https://github.com/russ) gave us a nice new feature with migrations allowing you to easily create a table partition.

    ```crystal
    Avram::Migrator::CreateTableStatement.new(:events).build do
      add id : Int64
      add type : Int32
      add message : String
      add_timestamps

      composite_primary_key :id, :created_at
      partition_by :created_at, type: :range
    end
    ```

    This allows you to start partitioning your tables by `:range`, `:list`, or `:hash` on
    whichever column you'd like.

    [Read more in the PR](https://github.com/luckyframework/avram/pull/1110)

    ### Redis Cache

    [LuckyCache](https://github.com/luckyframework/lucky_cache) received a few updates for the first time in 3 years.
    A small memory leak was fixed as well as support for Arrays.

    Along with that, a new [LuckyCache::RedisStore](https://github.com/luckyframework/lucky_cache_redis_store) shard was
    created by [@rmarronnier](https://github.com/rmarronnier) as a plugin allowing you to move that cache from memory store.

    ```crystal
    require "lucky_cache_redis_store"

    LuckyCache.configure do |settings|
      settings.storage = LuckyCache::RedisStore.new(
        Redis::Client.new(host: "localhost", port: 6379),
        prefix: "myapp:cache:"
      )
      settings.default_duration = 5.minutes
    end
    ```

    [Take a look at the RedisStore shard](https://github.com/luckyframework/lucky_cache_redis_store)

    ### Action body limits

    Lucky has supported middleware that allows you to limit the maximum size of incoming requests for a
    few years. Thanks to [@watzon](https://github.com/watzon), we now have a way to customize the limit
    on a per-action basis!

    Maybe your global restriction is set to 10MB, but you have a specific endpoint where you need to
    allow larger uploads. In that case you can, increase the limit on that specific action.

    ```crystal
    class Api::Videos::Create < Lucky::Action
      set_request_body_limit 100_000_000 # 100MB

      post "/videos" do
        # ...
        json({result: "ok"})
      end
    end
    ```

    [Read more in the PR](https://github.com/luckyframework/lucky/pull/2004)

    ## Parting words

    I would like to shout-out [@akadusei](https://github.com/akadusei) for the help and advice given during
    this release. They provide so many useful tools for the Lucky community through their business,
    [GrottoPress](https://github.com/grottopress).

    I'd also love to give an extra special shout-out to [@wout](https://github.com/wout) for all of the amazing work
    done on this release. Wout has been an integral part of this community by providing excellent shards
    such as [Rosetta](https://github.com/wout/rosetta) for language translations, and the new [Latch](https://github.com/wout/latch)
    for file uploads as well as all of the original work to integrate Vite and now Bun.
    Check out their venture [Fluck](https://codeberg.org/fluck).

    And lastly, thanks to all of the other contributors who help to shape this framework and make it special.

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [BlueSky](https://bsky.app/profile/luckyframework.org).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
