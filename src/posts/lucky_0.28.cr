class Lucky028Release < BasePost
  title "Lucky v0.28 is out and full of QoL updates, and features"
  slug "lucky-0_28-release"

  def published_at : Time
    Time.utc(year: 2021, month: 7, day: 26)
  end

  def summary : String
    <<-TEXT
    With the recent Crystal Conf behind us, we
    were able to finish up this release for Lucky
    0.28 and compatibility with Crystal 1.1.0! Let's
    recap the conference, and highlight some of the changes.
    TEXT
  end

  def content : String
    <<-MD
    In case you missed it, there was a [Crystal Conference](https://crystal-lang.org/conference/)
    on July 8th, 2021. There were some incredible talks by some amazing individuals like the
    creator of Ruby, [Yukihiro 'Matz' Matsumoto](https://github.com/matz), the creator of Crystal,
    [Ary Borenszweig](https://github.com/asterite), and the creator of the Open Source Definition
    [Bruce Perens](https://github.com/BrucePerens). We saw many facinating talks like Dynamic Crystal by
    [Kirk Haines](https://github.com/wyhaines) and fun artistic stuff by [Ian Rash](https://github.com/sol-vin).
    We even had [Stephen Dolan](https://github.com/stephendolan/) and [Jeremy Woertink](https://github.com/jwoertink/)
    from our Lucky core team give some incredible talks. Big shout-out to all that gave talks, attended
    the conference, and especially those that helped put it together like [Lorenzo Barasti](https://twitter.com/lbarasti)
    , and [Martin Pettinati](https://manas.tech/staff/mpettinati/)

    The conference was great, and it was so amazing to see how Crystal is being used in different
    ways by everyone. On top of putting on a great conference, the Crystal team also managed to
    release Crystal 1.1.0! We've released Lucky 0.28 which has compatibility with the latest Crystal.

    [Lucky v0.28](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md)
    is officially out. This ended up being a bit larger than we anticipated, but
    now we have a clear path to getting Lucky 1.0.0 out. This release is full of some pretty awesome
    features, and a lot of quality-of-life improvements.

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-025-to-026).

    Or you can view the changes using [LuckyDiff](https://luckydiff.com/?from=0.27.2&to=0.28.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    ### Dropped support for Crystal 0.36

    Crystal 1.0 has been out for a while now, and with the release of Crystal 1.1.0, we've
    decided to drop support for versions below 1.0 (0.36.1, etc...). This allows us to keep
    pushing forward, and utilize the latest updates to make Lucky even better.

    ### Spring Cleaning

    Many of the PRs in this release are under the hood improvements.

    * Removing old deprecated methods
    * Fixing compile-time error messages
    * File structure organization
    * Smaller and easier to understand CI configs
    * Small Performance gains in things like HTML tag rendering and param parsing
    * so many more...

    ### No more avram_enum

    When enums were first added to Avram, they were a bit tricky to implement. The
    native Crystal enums didn't work without lots of refactoring. Since the time it
    was first introduced, there's been enough refactoring to make adding native enums
    a reality. Thanks to [Matthew McGarvey](https://github.com/matthewmcgarvey/), we
    can delete a ton of code in our apps, and gain a lot flexibility!

    Before this change, your enums would look like this:

    ```crystal
    class StreamEvent < BaseModel
      avram_enum State do
        Started
        Waiting
        Ended
      end

      table do
        # NOTE: setting a default value here didn't work
        column state : StreamEvent::State
      end
    end

    # Saving the record
    SaveStreamEvent.create!(state: StreamEvent::State.new(:started))

    # Query for the record
    StreamEventQuery.new.state(StreamEvent::State.new(:started).value)
    ```

    Now after the change, your enums look like this:

    ```crystal
    class StreamEvent < BaseModel
      enum State
        Started
        Waiting
        Ended
      end

      table do
        # NOTE: now you can have default values
        column state : StreamEvent::State = StreamEvent::State::Started
      end
    end

    # Saving the record. It has a default value...
    SaveStreamEvent.create!

    # Query for the record
    StreamEventQuery.new.state(StreamEvent::State::Started)
    ```

    ### New JSON serializable columns

    Working with jsonb columns can be a bit tedious. Prior to this release, you
    had to define your `JSON::Any`, and manually build out the structure you wanted.
    With larger structures, you may have wanted to write some code like this:

    ```crystal
    table do
      column data : JSON::Any
    end

    # This is easy to read, but comes at a huge performance cost...
    JSON.parse(some_data_hash.to_json)

    # This can get real messy real quick...
    JSON::Any.new({"key" => JSON::Any.new(some_data_hash["key"])})
    ```

    Thankfully the [Crystal PG](https://github.com/will/crystal-pg/pull/232) shard now
    has the ability to not parse the jsonb field from postgres immediately. This allowed
    us to introduce serializable objects as columns! Now we can do this:

    ```crystal
    table do
      column data : ReportData, serialize: true
    end

    class ReportData
      include JSON::Serializable
      property key : String
    end
    ```

    Our jsonb columns now have more type-safety!

    [read more](https://github.com/luckyframework/avram/pull/695) in the PR.

    ### Support for subdomains

    In your application, you may have sections of your site that require a subdomain
    to access. For example, a separate API with `api.yoursite.com`, or maybe logging
    in to the site sends you to a `dashboard.yoursite.com`.

    Before this update, you had to use `request.hostname.as(String).split('.').first`
    to get the subdomain value, then use a before pipe to direct your traffic to the
    correct location. Now we have built-in subdomain support to handle this.

    ```crystal
    class Users::Index < BrowserAction
      # yoursite.com/users
      get "/users" do
        #...
      end
    end

    class ApiAction < Lucky::Action
      # Include this module in your actions
      # that need subdomains
      include Lucky::Subdomain
    end

    class Api::Users::Index < ApiAction
      require_subdomain "api"

      # api.yoursite.com/api/users
      get "/api/users" do
        #...
      end
    end
    ```

    This can have so many uses, like only access these actions under the "qa" subdomain,
    or a multitenant application, or even just a staging environment.

    [read more](https://github.com/luckyframework/lucky/pull/1537) in the PR.

    ### Action updates

    Actions got a few small updates starting with a new `multipart?` helper
    method that returns `true` when the request is multipart (i.e. uploading a file).
    This method accompanies the already existing methods `ajax?`, `xml?`, `plain_text?` and
    a few others.

    Along with the new helper methods, there's also two new response methods, `raw_json`,
    and `html_with_status`.

    The current `json()` response method is used to take a serializable object, and convert
    that to a JSON response. In some cases, for example GraphQL, you may have a raw JSON string.
    You couldn't use `json()` because this would convert your string in to an escaped json string.
    Now you don't have to build out the response manually. Just use `raw_json()` instead.

    Lastly is the `html_with_status`. More often than not, if you're rending an HTML page, it's
    going to be a 200 response from the server. Lucky handles the error responses like 404, 422, and
    500 for you in a separate action, so there's usually no reason to change this.

    However, Lucky believes in having an escape hatch for those times you need to do non-standard things.
    If you need to render an HTML page that's not a 200 response, you can use `html_with_status`

    ```crystal
    get "/tea_party" do
      # render the IndexPage with status 418
      html_with_status IndexPage, 418
    end
    ```

    ### Disable FLoC

    Google now has the [Federated Learning of Cohorts](https://github.com/WICG/floc) or "FLoC" for short,
    which is used for advertisers to track browsers that focus on privacy.

    Here's a quote taken from that Github Repo:

    > A FLoC cohort is a short name that is shared by a large number (thousands) of people,
    > derived by the browser from its user’s browsing history. The browser updates the cohort
    > over time as its user traverses the web. The value is made available to websites via a
    > new JavaScript API

    By enabling FLoC, you're allowing the browser to track your users in these cohorts. Lucky
    has decided to disable this feature for all new applications. If you would like your
    application to use FLoC, it's super easy to re-enable, just remove the module include!

    ```crystal
    class BrowserAction < Lucky::Action
      # Remove this include to enable FLoC tracking
      include Lucky::SecureHeaders::DisableFLoC
    end
    ```

    ### LuckyEnv

    With [LuckyEnv](https://github.com/luckyframework/lucky_env) joining the Lucky ecosystem,
    we now have our own shard to handle your environment variables a little nicer. The old
    `Lucky::Env` module has now been moved in to the `LuckyEnv` shard. Existing apps will
    need to make a few updates, but new apps will use this by default.

    This change brings us a step closer to better environment variable management which
    will also lead to some cool updates down the road like type-safe ENV vars, or encrypted
    values, and so forth.

    ### Upserts

    An `upsert` is when you do a database operation that will take some values, and `UPDATE`
    a record if there's an existing record, or `INSERT` a new record with the provided values.

    Avram now has a new `upsert` method on your `SaveOperation` objects you can use to update
    an existing record, or create a new one if none exist.

    ```crystal
    class UpsertUserOperation < User::SaveOperation
      # Use the name and nickname columns to check
      # for existing records
      upsert_lookup_columns :name
    end

    # If a User record exists with the name "Jude", then we will
    # update that record with the "attending" column set to false.
    # If Jude is not in the DB, then we add him in with attending set to false
    PartyOperation.upsert!(name: "Jude", attending: false)
    ```

    The feature has been requested for a while, and we're stoked to have it in.

    [read more](https://github.com/luckyframework/avram/pull/334) on the PR.

    ### Tons more

    This was a huge release, so we can't get to everything. Feel free to check out the
    [CHANGELOG](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md) to see
    more. Here's a quick highlight on a few more favorites:

    * Support for Arrays in query params and `multi_select_input`
    * Components no longer need `context` passed around all over
    * Use `Appdatabase.listen` to roll your own pub/sub from postgres
    * New `.any?` and `.none?` query methods
    * `DeleteOperation.destroy` renamed to `DeleteOperation.delete`
    * Customizing inflections with `Wordsmith` work
    * The `select_count` method is a little faster, and works on a ton more queries
    * `before_save` and `after_save` callbacks in Factories
    * Standardized routing checks

    ## Parting words

    This release gave us a lot of clarity as to what we need before getting to Lucky 1.0.
    Our current plan is that we will be doing a 0.29 release next which will include more
    QoL improvements, and some features we still need to see before 1.0, as well as fleshing
    out issues with recently added features like the JSON serializable columns.

    After the next 0.29 release, we should be in a solid spot for 1.0.0.rc1. We want to ensure
    that the transition between the final pre 1.0 release and the official 1.0 release is buttery
    smooth. We need more people using Lucky and giving us feedback to better guides us with
    what works, and what needs some extra attention.

    If you haven't had a chance to try building an app, now's the perfect time to do so!

    As always, we appreciate the support everyone has given us!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    Learn tips and tricks with [LuckyCasts](https://luckycasts.com/).

    For questions, or just to chat, come say hi on [Discord](#{Chat::Index.path}).
    MD
  end
end
