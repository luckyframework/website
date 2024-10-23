class Lucky130Release < BasePost
  title "Lucky v1.3.0 has been released"
  slug "lucky-1_3_0-release"

  def published_at : Time
    Time.utc(year: 2024, month: 10, day: 23)
  end

  def summary : String
    <<-TEXT
    Closing out the final quarter of 2024 with Crystal 1.14.0 out and full
    compatibility with the new Lucky 1.3.0 release.
    TEXT
  end

  def content : String
    <<-MD
    Lucky v1.3.0 has been released. This is a smaller release to fix compatibility with Crystal 1.13.x and later.

    Read through the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)
    for all of the changes, but we will discuss some of the highlights here.

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-120-to-130).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=1.2.0&to=1.3.0).

    ## Here's what's new

    ### New MaximumRequestSizeHandler
    
    This is a new handler you can add to your server middleware stack allowing you to customize
    the maximum size your requests should allow. This may help you to prevent your app from being
    attacked with extra large file sizes or payloads.

    Add `Lucky::MaximumRequestSizeHandler.new` to your `src/app_server.cr` 
    
    ```crystal
    def middleware : Array(HTTP::Handler)
      [
        Lucky::RequestIdHandler.new,
        #...
        Lucky::MaximumRequestSizeHandler.new,
        #...
      ]
    end
    ```

    Then add a configuration for it in `config/server.cr`

    ```crystal
    Lucky::MaximumRequestSizeHandler.configure do |settings|
      settings.enabled = true
      settings.max_size = 10_485_760 # 10MB
    end
    ```
    
    ### More support for Windows
    
    Our previous release 1.2.0 added the ability to install the Lucky CLI on Windows using [Scoop](https://scoop.sh/),
    but booting the Lucky app still had quite a few issues.

    This release has put a lot more focus in to Windows compatibility with most of the eco system shards fully working.

    The following shards all now have Windows compatibility: [Lucky](https://github.com/luckyframework/lucky), [LuckyFlow](https://github.com/luckyframework/lucky_flow), [Carbon](https://github.com/luckyframework/carbon), [Pulsar](https://github.com/luckyframework/pulsar), [LuckyCache](https://github.com/luckyframework/lucky_cache), [LuckyRouter](https://github.com/luckyframework/lucky_router), [Habitat](https://github.com/luckyframework/habitat), [LuckyEnv](https://github.com/luckyframework/lucky_env), [LuckyTask](https://github.com/luckyframework/lucky_task), [Wordsmith](https://github.com/luckyframework/wordsmith), [LuckyTemplate](https://github.com/luckyframework/lucky_template), and [LuckySecTester](https://github.com/luckyframework/lucky_sec_tester).
    The final shard missing is [Avram](https://github.com/luckyframework/avram) (which is mainly held back by [this issue on PG](https://github.com/will/crystal-pg/issues/291)), and
    the [CLI itself](https://github.com/luckyframework/lucky_cli) which will be finalized once Avram is updated.

    If you're a developer using Windows, we would love the additional assistance. Reach out on [Discord](#{Chat::Index.path})
    if you have questions.
    
    ### Arbitrary CLI tasks
    
    One major issue that held Lucky back on Windows compatibility was the use of the `postinstall` scripts on Lucky, Carbon, and Avram.
    Previously, when installing these shards, they would need to run a bash script that would then precompile a few binaries
    for use with your app. For example, the `lucky gen.secret_key` task which generates a random unique key.

    Aside from these bash scripts not being directly usable on Windows, there's also been discussion that [postinstall can be "harmful"](https://forum.crystal-lang.org/t/shards-postinstall-considered-harmful/3910)
 and may possibly removed in a future version of Crystal. By removing the use of the postinstall,
    Lucky was able to do a few things:

    * Installing the shards is **way** faster since it no longer needs to stop and precompile several binaries
    * No more need for bash scripts to install Lucky making the installation process more portable and cross platform accessible
    * A refactor led to a new feature of arbitrary CLI tasks

    You can now create a simple Crystal file script and place it in your app's `bin` directory and name it `lucky.your.custom.task.cr`.
    To execute this script, just run `lucky your.custom.task`. You can compile this task in to a binary at any time you wish by running

    ```
    crystal build --release bin/lucky.your.custom.task.cr -o bin/lucky.your.custom.task
    ```

    Next time you execute this call, it'll run the compiled version instantly.

    > The next release, a new `lucky build` command will make this easier.
    
    ## Parting words

    Thank you for sticking with Lucky. While there's many options out there to choose from,
    it means a lot that you've chosen this framework. If you're using Lucky in production, and would like
    to add your application to our [Awesome Lucky](https://luckyframework.org/awesome) "built-with"
    section, feel free to open an issue on the [Website](https://github.com/luckyframework/website/issues)
    or a PR!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [X (formerly Twitter)](https://x.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
