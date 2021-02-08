class Lucky026Release < BasePost
  title "Lucky v0.26 Released and ready to go!"
  slug "lucky-0_26-release"

  def published_at : Time
    Time.utc(year: 2021, month: 2, day: 8)
  end

  def summary : String
    <<-TEXT
    Lucky v0.26 is the latest release, and loaded
    with some fun goodies!
    TEXT
  end

  def content : String
    <<-MD
    [Lucky v0.26](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-026)
    is out, and just like 0.25.0, this was another huge release! So many bug fixes, and even a few
    more goodies!

    ### How to upgrade

    See the [UPGRADE_NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-025-to-026).

    Or you can view the changes using [LuckyDiff](https://luckydiff.com/?from=0.25.0&to=0.26.0).
    This tool helps see what has changed between versions and will be included in upgrade notes from now on.

    ## Here's what's new

    ### Learn Lucky with LuckyCasts

    Our core-team member [Stephen Dolan](https://github.com/stephendolan/) has been cranking out some amazing videos you've probably watched
    on [YouTube](https://www.youtube.com/channel/UCZzMjXqNc4Z2Yv9C4Hw2veg). The website has been updated, and looks all fresh and clean now!

    Head on over to the all new [LuckyCasts](https://luckycasts.com/) site to start your Lucky learning experience.

    ### `Box` is now `Factory`

    In [#614 of Avram](https://github.com/luckyframework/avram/pull/614) we renamed `Avram::Box` to `Avram::Factory`.
    Even though this doesn't change how they work, it's still a breaking-change,
    and can require changes to a lot of code. We believe the term "Factory" will be more familiar to newcomers, and Crystal already has a [Box class](https://crystal-lang.org/api/0.35.1/Box.html). You can find the discussion about this [here](https://github.com/luckyframework/lucky/discussions/1282).

    Here's just a quick example of the change:

    ```crystal
    # BEFORE 0.26.0 UPDATE
    # spec/support/boxes/user_box.cr
    class UserBox < Avram::Box
      def initialize
        email "test@test.com"
      end
    end

    # AFTER 0.26.0 UPDATE
    # spec/support/factories/user_factory.cr
    class UserFactory < Avram::Factory
      def initialize
        email "test@test.com"
      end
    end
    ```

    ### Reverted the `after_completed` callback

    In the [0.25.0 Release](#{Blog::Show.with(Lucky025Release.new.slug)}) we added the `after_completed` callback to `Avram::SaveOperation` in order to handle a specific edge case.
    When calling `SaveSomeObject.update(...)`, if there were no changes to that object, then no callbacks would run. The `after_completed`
    callback fixed this issue.

    For this release, we've made the decision to always run `after_save` and `after_commit` whether your object has changes to commit to the database or not.
    The benefit of code running how you'd expect outweighed any performance benefit we gained from not running them.

    [Read more](https://github.com/luckyframework/avram/pull/612) on this change.

    ### New CLI tasks

    Lucky 0.26.0 adds in two new tasks

    * `lucky gen.task SomeTask` - Now a task to generate a new task! [read the PR](https://github.com/luckyframework/lucky/pull/1322)
    * `lucky db.console` - A task to enter the `psql` console without having to type your credentials [read the PR](https://github.com/luckyframework/avram/pull/592)

    ### Delete Operations

    You've heard of SaveOperations, well now welcome DeleteOperations to the family!

    Deleting records from the database is generally straight forward, but in some cases you may need a little more complex logic. Maybe an object can only be
    deleted if the `current_user` has certain permissions. Maybe special tasks need to happen after the object is deleted (i.e. clearing cache, etc...).
    Or in many cases, it's becoming more common practice to require a user to "confirm" by typing that they really do want to delete.
    For these use cases, we now have the DeleteOperation.

    Every model has a DeleteOperation that you can inherit from the same as the SaveOperation. Here's an example:

    ```crystal
    # src/operations/delete_repo.cr
    class DeleteRepo < Repo::DeleteOperation
      attribute confirm_delete : String

      before_delete do
        if confirm_delete.value != "luckyframework/\#{git_name.value}"
          confirm_delete.add_error("You must confirm the delete")
        end
      end

      after_delete do |deleted_repo|
        CacheSweeper.run!("luckyframework/\#{deleted_repo.git_name}")
      end
    end

    # src/actions/repos/delete.cr
    class Repos::Delete < BrowserAction
      delete "/repos/:repo_id" do
        repo = RepoQuery.find(repo_id)

        DeleteRepo.destroy(repo) do |operation, deleted_repo|
          if operation.deleted?
            flash.success = "The repo \#{deleted_repo.git_name} has been deleted"
            redirect to: Home::Index
          else
            TimeBomb.start_countdown(10.seconds)
          end
        end
      end
    end
    ```

    [Read more](https://github.com/luckyframework/avram/pull/573) on this feature.

    ### CIText Support

    This was new to some of us that had never even heard of "citext" before. The "citext" column in postgres is "Case-Insensitive Text". This allows you to
    store a string in your database, and do lookups against it without the need to do something like `"WHERE LOWER(email) = ?", email.downcase`. Instead, your
    users could spell their email like "LucKyDawG@gmAIl.com" and still log in with "luckydawg@gmail.com".

    By default, all `String` columns in Avram are case sensitive, but if you'd like to use this citext column, just add `case_sensitive: false` to your migrations!

    ```crystal
    # NOTE: You must enable the extension for this feature to work!
    enable_extension "citext"

    create table_for(User) do
      add name : String
      add email : String, case_sensitive: false
    end
    ```

    [Read more](https://github.com/luckyframework/avram/pull/608) on this feature.

    ### More updates to LuckyFlow

    With the release of LuckyFlow 0.7.2, [matthewmcgarvey](https://github.com/matthewmcgarvey) has
    worked his magic to bring us the ability to watch our Flow specs in real time!

    Generally, you would run your specs in "headless" mode, meaning you'd never see the browser
    interaction. Before this release, the only way to know what your specs were doing was to take a
    screenshot at some point in your flow. Now, you can run it headfully. This means when you start
    your specs, you'll see a browser window open and interact in real time.

    To set this up, you'll update `spec/setup/configure_lucky_flow.cr`

    ```crystal
    # spec/setup/configure_lucky_flow.cr
    LuckyFlow.configure do |settings|
      settings.stop_retrying_after = 200.milliseconds
      settings.base_uri = Lucky::RouteHelper.settings.base_uri

      # Add this setting
      settings.driver = LuckyFlow::Drivers::Chrome
    end
    Spec.before_each { LuckyFlow::Server::INSTANCE.reset }
    ```

    LuckyFlow also now comes with the ability to `pause` your specs. This will temporarily halt
    the browser test while you take your time to inspect and debug. Then you can easily continue
    by pressing your enter/return key from the console.

    ```crystal
    flow = PublishPostFlow.new

    flow.start_draft
    flow.create_draft

    flow.pause # Head back to your terminal to resume

    flow.open_draft
    flow.publish_post
    flow.post_should_be_published
    ```

    ### Ditching `route` and `nested_route`

    Lucky comes built with two special macros `route` and `nested_route` which automatically define both the HTTP Verb, and the actual request path for your actions.
    This is nice because `Users::Index` magically becomes `get "/users"`, and `Users::Comments::Index` is turned in to `get "/users/:user_id/comments"`. It cleans
    up your code a little, and makes things consistent.

    The downside to this is, what does `Admin::Report::Spending` become, or how about `Git::Push`? The `route` and `nested_route` macros work great when you're
    building simple REST related resources, but in more complex cases, you end up writing your routes out manually. This means your actions are no longer written consistently.

    Updating your actions should be pretty straight forward.

    * Run the `lucky routes` task to get a list of the full generated routes.
    * Replace `route` and `nested_route` with the generated routes shown in the `lucky routes` output.

    ```crystal
    # Before Update
    class Users::Index < BrowserAction
      route do
        # ...
      end
    end

    # After Update
    class Users::Index < BrowserAction
      get "/users" do
        # ...
      end
    end
    ```

    Read this [PR](https://github.com/luckyframework/lucky/pull/1378) and this [PR](https://github.com/luckyframework/lucky_cli/pull/594). Also expect the docs related to
    these to be dropped soon.

    ### So much more!

    Here's a few goodies we don't have time to cover:

    * Test if an email was sent with `have_delivered_emails` expectation
    * Use `has_one` in your `SaveOperation`
    * Support for `Array(UUID)` column types
    * New `validate_numeric` validation
    * A new [Heroku buildpack](https://github.com/luckyframework/heroku-buildpack-lucky) for (slightly) faster deploys
    * Starting work to support composite primary keys

    Read through the [CHANGELOG](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md) to see it all!

    ## Parting words

    Each release we make lots of strides towards hitting our goal of a solid 1.0 release. You can help us by building an app!
    Build anything, and let us know your thoughts. What do you like, what would you like to see improved?

    If you find any issues, don't hesitate to [report them](https://github.com/luckyframework/lucky/issues).
    If you're unsure, just hop on [Discord chat](https://discord.gg/HeqJUcb) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on GitHub](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    Learn more about Lucky with the all new [LuckyCasts](https://luckycasts.com/)!

    For questions, or just to chat, come say hi on [Discord](https://discord.gg/HeqJUcb).
    MD
  end
end
