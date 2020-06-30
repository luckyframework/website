class Lucky023Release < BasePost
  title "Lucky v0.23 is out, and it's huge!"
  slug "lucky-0_23-release"

  def published_at : Time
    Time.utc(year: 2020, month: 6, day: 30)
  end

  def summary : String
    <<-TEXT
    Lucky v0.23 is out now. Lots of new features, bug fixes,
    improved performance, more powerful tests, and more!
    TEXT
  end

  def content : String
    <<-MD
    [Lucky v0.23](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-023)
    is out now and works with the newest version of Crystal (v0.35.0)

    Be sure to upgrade your version of Crystal, and take a look at our
    [UPGRADE NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-022-to-023)
    for help with migrating your app.

    ### How to upgrade
    
    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-022-to-023) to learn how to upgrade to Lucky 0.23.0.

    Special thanks to community member [@stephendolan](https://github.com/stephendolan) for
    creating [LuckyDiff](https://luckydiff.com). This tool helps see what has changed between versions and will be included in upgrade notes from now on. 

    ### What happened to 0.22.0?

    Don't worry, you didn't miss anything. If you're using Lucky 0.21.0, you can upgrade to
    [0.22.0](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#v0220-2020-06-17) just by
    updating your Crystal version to 0.35.0. This release didn't change anything other than compatibility
    with the latest Crystal. To get all of the latest goodies, you'll want to go up to 0.23.0.

    ## Here's what's new

    ### `mount` is now `m`

    We have deprecated the use of `mount` in favor of a shorter method `m`. The structure of this
    is a little bit different.

    ```crystal
    # Before
    mount MyComponent.new(arg: 1)

    # After
    m MyComponent, arg: 1
    ```

    You still have all the flexibility, but in a more compact version. The new `m` method also opens the doors for more functionality that we'll be adding to components in future releases of Lucky.

    ### Trim extra whitespace in params

    Leading and trailing whitespace is now stripped automatically when accessing params. If you need to get the unstripped value, you can use `params.get_raw(:the_key)`.

    ```crystal
    # the user sends the email param as " email@email.com "
    params.get(:email) #=> "email@email.com"
    params.get_raw(:email) #=> " email@email.com"
    ```

    ### Revamped memoization

    The `Memoizable` module got a nice little upgrade. It now supports arguments, as well as
    `false` and `nil` values. 

    ```crystal
    memoize user(user_id : Int64) : User?
      UserQuery.new.find(user_id)
    end
    ```

    Now when you call this method, it will run the first time, and return the value even if that value is
    `nil`. If you need access to the uncached version you can use the `__uncached` version of the method.

    ```crystal
    # run the query once, and always return that value
    user(4)

    # always run the query and return the value
    user__uncached(4)
    ```

    ### Security and more
    
    Some of the HTML page helpers like `highlight`, and `simple_format` would allow for unescaped HTML.
    This could potentially be a security issue, so that's been fixed. All of these methods will escape the
    HTML by default now. If you need the unescaped version, you can pass `escape: false`.

    ```crystal
    highlight("<p>This is a beautiful morning, but also a beautiful day</p>", "beautiful", escape: false)
    ```

    We've also fixed a few issues related to cookies.
    * You can now set a `samesite` default.
    * Exceptions aren't raised when trying to delete a cookie that doesn't exist

    ## Routing Updates

    We have added a new `route_prefix` macro that alllows you to prefix your routes with
    some path. This really helps with APIs where you may want to prefix all your routes with
    something like `/api/v1`.

    ```crystal
    abstract class ApiAction < Lucky::Action
      accepted_formats [:json], default: :json

      route_prefix "/api/v1"
    end

    class Posts::Index < ApiAction
      # GET /api/v1/posts`
      get "/posts" do
        #...
      end
    end
    ```

    On top of all the neat routing features, we were also able to squeeze a little more performance
    out thanks to [@matthewmcgarvey](https://github.com/luckyframework/lucky_router/pull/26)!

    ## CLI Task Args

    Writing CLI tasks for your application are pretty common, but they can also be a bit complicated.
    Lucky now makes it easier to write custom CLI tasks with arguments.

    We break CLI arguments in to 3 types:

    * `arg` - This is the most standard CLI argument type. e.g. `-m User` or `--model=User`.
    * `switch` - Just like `arg`, but without a value. Returns `true` if this flag is passed. e.g. `-v`, `-h`
    * `positional_arg` - When you want to pass args that are not flags. Lucky uses this with generators like
      `lucky gen.page About` where `About` is a positional arg.

    ```crystal
    # lucky search.reindex User
    class Search::Reindex < LuckyCli::Task
      summary "Reindex records for a model"
    
      positional_arg :model, "Specify which model to reindex", required: true
    
      def call
         # made up code to reindex User
         Elasticsearch.reindex(model: model)
      end
    end
    ```

    ```crystal
    # lucky import_data --dry
    class ImportData < LuckyCli::Task
      summary "Import the latest data"
    
      switch :dry, "Perform a dry run before the actual import", shortcut: "-d"

      def call
        if dry?
          # ...
        else
          # ...
        end
      end
    end
    ```

    ```crystal
    # lucky generate_sitemaps --environment=dev
    class GenerateSitemaps < LuckyCli::Task
      summary "Generate some sitemaps"
      arg :environment, "Specify the ENV for the sitemaps", format: /(dev|prod)/
    
      def call
        # ...
       end
    end
    ```

    ## Lucky Flow

    The underlying shard that LuckyFlow wraps has been replaced with the selenium shard by
    [@matthewmcgarvey](https://github.com/matthewmcgarvey/selenium.cr). This update allows us to support all browsers and not just Chrome. On top of that,
    we can now stay up-to-date with the new W3C WebDriver standard going forward.
    
    It also automatically installs the correct driver for your version of Chrome so browser testing is easier than ever to get started with.

    For the most part, everything still works as it did before, just with a shiny new engine!

    ## Parting words

    This release has seen a huge surge in community contributions. It's tough maintaining
    open source projects, so we just want to say how much we appreciate all of the hard work
    the community has put in to Lucky making this framework so amazing!

    We're really excited about getting closer to a 1.0 release, and we can't do it without
    your support. Please give it a spin and help us find bugs so our next release is even more solid.
    If you find any issues, don't hesitate to [report the issue](https://github.com/luckyframework/lucky/issues).
    If you're unsure, just hop on [gitter chat](https://gitter.im/luckyframework/Lobby) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [gitter](https://gitter.im/luckyframework/Lobby).
    MD
  end
end
