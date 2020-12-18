class Lucky025Release < BasePost
  title "Lucky v0.25 is hot off the press, and there's a lot!"
  slug "lucky-0_25-release"

  def published_at : Time
    Time.utc(year: 2020, month: 12, day: 18)
  end

  def summary : String
    <<-TEXT
    Lucky v0.25 is out. A ton has changed,
    and we're full steam ahead to 1.0!
    TEXT
  end

  def content : String
    <<-MD
    [Lucky v0.25](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-025)
    is out now, and we have a ton to go over. Let's get to it!

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-024-to-025).

    Or you can view the changes using [LuckyDiff](https://luckydiff.com/?from=0.24.0&to=0.25.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    Since the last release we've welcomed two more developer to the core team, [Matthew](https://github.com/matthewmcgarvey) and [Stephen](https://github.com/stephendolan).
    They have been huge contributors in the community, and since bringing them on, the movement towards 1.0 has more than doubled in speed!

    Over the last few months, we've made a ton of changes, so let's break down a couple of the more notable ones:

    ### `Avram::Operation` got a facelift

    When you need to handle some logic that isn't tied directly to a single model, you can create an `Avram::Operation` to handle this. You've probably seen
    examples in your app like the `RequestPasswordReset` and `SignInUser` that come with an app generated with authentication.

    Prior to this update, it was sort of "wild west", and completely up to you on how to implement these. For consistency sake, we recommended defining a `submit`
    method, and then returning `yield self, value`. These operations were also limited as they couldn't use callbacks, file attributes, or define errors not tied to
    an attribute.

    In this release, we've created a whole new interface!

    ```crystal
    class PromoteUserValidator < Avram::Operation
      param_key :user
      needs user : User
      attribute token : String

      # before callbacks
      before_run do
        if user.has_inactive_account?
          # custom errors
          add_error(:user_inactive, "My custom error message")
        end

        validate_required(token)
      end

      # after callbacks
      after_run do |user|
        NotifyUser.new(user.email).deliver
      end

      # unified interface
      def run
        if user.is_promotable?
          user
        else
          nil
        end
      end
    end

    PromoteUserValidator.run(params) do |operation, user|
      if user
        # the user must be promotable
      else
        # no user, lets check our custom error
        operation.errors[:user_inactive]
      end
    end
    ```

    ### Better callbacks in `Avram::SaveOperation`

    We've also made quite a few changes to the `Avram::SaveOperation` family as well.

    Prior to this update, your `after_save` and `after_commit` callbacks couldn't be used with an anonymous block like how `before_save` works. Well,
    now they can!

    ```crystal
    class SaveUser < User::SaveOperation
      before_save do
        # before save
      end

      after_save do |saved_user|
        # after save
      end

      after_commit do |saved_user|
        # after DB commit
      end
    end
    ```

    We've also added the ability to conditionally trigger these callbacks based on a method.

    ```crystal
    class SaveUser < User::SaveOperation
      before_save :validate_card_number, if: :new_transaction?

      after_save :update_billing, unless: :card_still_valid?

      private def validate_card_number
      end

      private def new_transaction?
        true
      end

      private def update_billing
      end

      private def card_still_valid?
        false
      end
    end
    ```

    We've added one additional callback called `after_completed`. This callback is always called when the operation is successful (the internal `save_status` attribute is set to `:saved`).
    This means that even if the record never touches the database, the `after_completed` callback will still run.

    ```crystal
    class SaveUser < User::SaveOperation

      after_commit do |updated_user|
        # This is only called if something on the user actually changed
        AfterCommitJob.perform(updated_user.id)
      end

      after_completed do |updated_user|
        # This is always called if the user is saved
        MetricsUpdaterJob.perform(updated_user.id)
      end

    end
    ```

    ### `with_defaults` is now `tag_defaults`

    When you create components like `Shared::Field`, you can use the `tag_defaults` method to apply default attributes to a set of HTML elements.
    This method was called `with_defaults` before, but has been renamed for some clarity on what it does.

    ### Changes to the Query objects

    The `Query` objects also got a few new changes. The main one being that queries no longer mutate the object. Prior to this release, appending any
    query method would mutate the original object. This made building queries nice and easy, but presented a problem that many faced. For example:

    ```crystal
    q = UserQuery.new

    # this would fail because we've already mutated the query
    # on the count, and can no longer query with the username ordering
    user_total_count = q.select_count
    users = q.username.asc_order
    ```

    In that case, you had to make sure you cloned the query, and the chained methods were called in the correct order. We no longer mutate the query, but this requires a code change.

    ```crystal
    q = UserQuery.new

    user_total_count = q.select_count
    users = q.username.asc_order
    ```

    With this change, this also means that defining default queries in your query class `initialize` need to change. To set a default, you'll now use the `defaults` method.

    ```crystal
    class AdminQuery < User::BaseQuery
      def initialize
        defaults &.admin(true)
      end
    end
    ```

    ### Type-safe WHERE "OR"

    This was one of our most common requests! We held off since adding this in makes SQL queries quite a bit more complex, but we finally got it! (**sort of... see note below)

    ```crystal
    # WHERE users.name = 'Billy' OR users.name = 'Kelly'
    UserQuery.new.name("Billy").or(&.name("Kelly"))
    ```

    Calling the `or` method which passes in the instance of the query object allowing you to chain additional WHERE clauses.

    **NOTE: The above example works great, and will cover plenty of the queries that you may have, but we currently make no assumptions on where to place parenthesis for scoping
    order of operations. Take this for example:

    ```crystal
    UserQuery.new.name("Billy").or(&.name("Kelly").age.gte(51)).or(&.admin(true))
    ```

    This query would generate `WHERE name = 'Billy' OR name = 'Kelly' AND age >= 51 OR admin = true`, and that may not give you the result you expect. We are working on a solution,
    but for now if you need more complex control, you can pass raw SQL to `UserQuery.new.where("name = ? OR (name = ? && age >= ?)", "Billy", "Kelly", 51)`.

    ### Model Association updates

    When you're using an RDBMS like PostgreSQL, table associations become very important for properly structuring your data. There were several bugs fixed when it comes to
    associations giving you a lot more power and control over your data.

    To start, let's look at the `belongs_to` association method. It's pretty common for the method name to be the same as the model it's referencing, but in some cases,
    you may want your association method to be named something different:

    ```crystal
    class Employee < BaseModel
      table do
        belongs_to boss : Manager
      end
    end
    ```

    But this would throw an error due to how the query methods were generated.
    In some places we were using the table name to generate code, and in others we were using the association name.

    With this release, we no longer make the assumption on what you're naming your associations. But it's also worth pointing out that `where_` query
    methods will append the name of the association.

    ```crystal
    EmployeeQuery.new.where_boss(ManagerQuery.new)
    ```

    We've also fixed some bugs related to using `has_many through`. This update will require a slightly different syntax.

    ```crystal
    # Before update
    class User < BaseModel
      table do
        has_many posts : Post

        # you specified the Symbol of the has_many method to query through
        has_many comments : Comment, through: :posts
      end
    end

    # After update
    class User < BaseModel
      table do
        has_many posts : Post

        # you specify an Array(Symbol) where the first item is the method to query through
        # and the second item is that association's method.
        has_many comments : Comment, through: [:posts, :comments]
      end
    end
    ```

    Related to this change, we've also fixed bugs that limited the types of associations that could be used for the "through" association 😬

    ### Models now support SQL VIEW

    Generally when we think of models, we think of database tables. The models even have a `table()` method to denote this.
    Well now there's a `view()` method as well!

    > SQL VIEWs are like tables, but generally READ-ONLY, and might not have a primary key. Their data is usually aggregated from other table sources.

    ```crystal
    class AdminUser < BaseModel
      view do
        column username : String
        column promoted_to_admin_on : Time
      end
    end
    ```

    All of the columns for your `view` must be manually defined. These models do not come with any sort of `primary_key` or `timestamps` by default. If your view has these columns, you will need to explicitly add them.
    View models will not have a `SaveOperation` defined as they are meant to be read-only, and if no primary key is added, some features will be missing from the model and `BaseQuery`.
    For example, `AdminUserQuery.find()` and `admin_user.reload` won't work since these rely on an `id` method.
    You must implement any of these methods yourself if you need them.

    ### Routing Changes

    The LuckyRouter got some fancy upgrades that we're super stoked about! The first one is "glob" routing.

    Glob routes are a route where the first part in the path is known, but the end of the route path is a variable length. For example:

    ```
    myblog.com/posts
    myblog.com/posts/2020
    myblog.com/posts/2020/12
    myblog.com/posts/2020/12/25
    ```

    If these routes all display posts, it's not useful to duplicate routes or pages over multiple actions. In this case, we can define a glob route
    to catch all of these in to the same action.

    ```crystal
    class Posts::Index < BrowserAction
      get "/posts/*:date" do
        date_parts = date.try(&.split('/')) || [] of Int32

        year = date_parts[0]?
        month = date_parts[1]?
        day = date_parts[2]?

        html IndexPage, posts: PostQuery.new.by_date(year, month, day)
      end
    end
    ```

    Another great update to the router is that Lucky can now catch overridden (duplicate) routes. This helps catch mistakes in development, especially in large project where hundreds or more routes are defined.

    ```crystal
    # These will now raise an error when starting the app

    class Api::Posts::Show < ApiAction
      get "/api/posts/:id" do
        #...
      end
    end

    class Api::Posts::SearchByYear < ApiAction
      get "/api/posts/:year" do
        #...
      end
    end
    ```

    ### And much more!

    This blog post could go on for days to include all the awesome stuff we've added. Here's a quick run down of a few more:

    * Updates and new features to LuckyFlow like hover over element
    * More bug fixes in associations and file handling
    * Global use of `memoize` in any class
    * Testing CLI Tasks is easier
    * Lots of cleanup, and refactors

    Read through the [CHANGELOG](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md) to see it all!

    ## Parting words

    This is another step towards 1.0, and we're super stoked. We can't do this without continued support from our community.
    The more hands and eyes on the project, the more fine tuned Lucky can be!

    Please give it a spin and help us find bugs so our next release is even more solid.
    If you find any issues, don't hesitate to [report them](https://github.com/luckyframework/lucky/issues).
    If you're unsure, just hop on [Discord chat](https://discord.gg/HeqJUcb) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [Discord](https://discord.gg/HeqJUcb).
    MD
  end
end
