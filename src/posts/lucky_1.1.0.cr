class Lucky110Release < BasePost
  title "Welcome Michael, and Lucky 1.1.0"
  slug "lucky-1_1_0-release"

  def published_at : Time
    Time.utc(year: 2023, month: 10, day: 31)
  end

  def summary : String
    <<-TEXT
    Let's officially welcome Michael to the Core team,
    and break down the latest Lucky 1.1.0 release, then
    discuss what's coming up in the future.
    TEXT
  end

  def content : String
    <<-MD
    We would like to officially welcome [Michael](https://github.com/mdwagner/) to the core team!
    Michael has been hard at work creating a lot of new shards in the Lucky eco system, as well
    as working on several large refactors across Lucky allowing the framework to work on Windows.

    To add to this great news, we've also released another version of Lucky. Lucky v1.1.0 is out.
    As always, you can read through the [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md)
    for all of the changes, but we will discuss some of the highlights here.

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-100-to-110).

    You can also view the changes using [LuckyDiff](https://luckydiff.com/?from=1.0.0&to=1.1.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    ### New LuckyCLI Interface

    The `lucky` command line interface received a needed overhaul by utilizing Crystal's buil-in
    [OptionParser](https://crystal-lang.org/api/latest/OptionParser.html) a little more, and moving
    around some logic.

    Previously, just running `lucky -h` would require compiling your app. This was because the `lucky -h`
    command would print out a list of all the custom tasks available in your application. This list can
    change without notice, and requires a compilation each time.

    Now, when running `lucky -h`, you get the help menu instantly as you would normally expect. The list
    of custom tasks is still available to you, but through the `lucky tasks` command. This will be a nicer
    dev UX for new users to Lucky.

    On top of the nicer UX, the underlying code generation for generating new applications has received an
    overhaul itself. Before this release, we would run `crystal init app` under the hood, then delete the
    files we didn't need, rename a few files, and finally fill in the remaining files for the project structure.
    This was overly complex, and added steps that were not neccessary. With this release, Lucky will generate
    all of the files needed from the start. This also happens in a manner that is now cross-platform compatible
    which will allow LuckyCLI to build on Windows.

    ### New Shards

    Thanks to the hard work Michael has put in, we have a few new shards added to the Lucky ecosystem.

    [LuckyTemplate](https://github.com/luckyframework/lucky_template) is a shard used for generating
    project templates. This shard has deprecated our previous [Teeplate](https://github.com/luckyframework/teeplate)
    shard. LuckyTemplate was built with a focus on cross-platform compatibility, and the templating was
    one of the issues holding us back from supporting Windows. With this shard, the majority of our
    shards are now fully Windows compatible!

    [LuckyHXML](https://github.com/luckyframework/lucky_hxml) is an extension to Lucky wich allows
    you to generate backend code used for making mobile applications in [Hyperview](https://hyperview.org/).
    By utilizing the structure that Lucky provides for HTML, the LuckyHXML shard mimics this in a
    familiar way allowing you to build type-safe mobile apps with compile-time catches for the
    front-end of your mobile application.

    [LuckyHTMX](https://github.com/watzon/lucky_htmx) is a shard extension to make working with the
    popular [HTMX](https://htmx.org/) library a little easier. While this shard is unofficial and maintained by a community member, a few changes in Lucky v1.1.0 were needed to allow htmx compatibility. For example, to use `hx-boost`,
    you must return a 303 redirect response. One change made in this version of Lucky allows you to
    set your default redirect status to 303 globally. Set it once and forget it.

    ### Changes to LuckyTask

    [LuckyTask](https://github.com/luckyframework/lucky_task) received a bit of an update too!
    If you're unfamiliar with this shard, it's the backbone to creating custom CLI tasks. Lucky
    ships with several pre-built tasks like `lucky db.create`, `lucky routes`, and `lucky dev`.

    this wasn't possible. This is because CLI arguments created instance methods and we had several instance
    methods reserved. We've fixed this, but it required a **breaking change**
    to existing tasks.

    Before the update, a custom task would look like this:

    ```crystal
    class GenerateSitemaps < LuckyTask::Task
      summary "Generates new sitemaps"
      name "gen.sitemaps"

      def help_message
        "Run 'lucky gen.sitemaps' to refresh the sitemaps"
      end

      def call
        # ...
      end
    end
    ```

    After the update the `help_message` moves to the class level with `summary` and `name`:

    ```crystal
    class GenerateSitemaps < LuckyTask::Task
      summary "Generates new sitemaps"
      name "gen.sitemaps"
      help_message "Run 'lucky gen.sitemaps' to refresh the sitemaps"

      def call
        # ...
      end
    end
    ```

    The three methods here `summary`, `name`, and `help_message` were all instance methods.
    By moving `help_message` to a macro, these are now generated as class level methods all
    prefixed with `task_`. (i.e. `task_summary`, `task_name`, `task_help_message`)

    ### JSON Serialized Arrays

    In a previous release of Avram, we added the ability to set columns as a serialized column.
    When using the `serialize: true` option on a JSON::Any column, it would serialize that column
    into an object.

    ```crystal
    class User < BaseModel
      struct Preferences
        include JSON::Serializable

        property theme : String
      end

      table do
        column preferences : User::Preferences, serialize: true
      end
    end
    ```

    With Avram v1.1.0, you can now store an array of these objects.

    ```crystal
    class User < BaseModel
      struct Contact
        include JSON::Serializable

        property name : String
      end

      table do
        column contacts : Array(User::Contact), serialize: true
      end
    end
    ```

    _Note: this stores the column as `'[]'::jsonb` which is a jsonb array of objects
    as opposed to `[]::jsonb[]` which is an array column of jsonb objects. The column
    is still `jsonb`._

    ### SecTester is fully Crystal

    In case you weren't aware, Lucky ships with direct integration with the [Bright Security](https://brightsec.com/)
    [SecTester](https://github.com/NeuraLegion/sec-tester-cr) by way of the [LuckySecTester shard](https://github.com/luckyframework/lucky_sec_tester).

    Once you have an API key to Bright, your Lucky app can run a number of security tests
    to ensure you're not introducing vulnerabilities on your site.

    Lucky v1.1.0 now ships with the latest SecTester v1.6.x series which ported the internal repeater
    over to Crystal. This means your application no longer needs to boot a NodeJS repeater in development
    or CI as a separate process.

    ### Coming down the pipe

    Here's just a few items that we are currently focused on for the next release.

    * Internal refactors to keep the codebase clean, and make contributing easier.
    * Getting more Windows support (Pending any remaining issues in Crystal).
    * Better dev UX for ares that still cause pain, like swapping out Avram.
    * Consistency across the shard ecosystem

    If there's anything you'd like to see, let us know!

    ## Parting words

    As with how OSS tends to go, there may be lulls in development from time to time, but Lucky
    is still going strong! It's being used in production by many companies, and our core team is
    growing.

    If you have hesitations about using Lucky, or there's features missing that you would need
    in order to start using Lucky, please let us know. You can join our [Discord](#{Chat::Index.path}),
    or open up a new [Discussion](https://github.com/luckyframework/lucky/discussions) on 
    Github so we can help make Lucky even better.

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [X/Twitter](https://twitter.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    If you have any questions, or just want to chat, please join us on [Discord](#{Chat::Index.path}).
    MD
  end
end
