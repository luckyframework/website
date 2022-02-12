class Lucky020Release < BasePost
  title "Lucky v0.20 is one of our biggest releases yet."
  slug "lucky-0_20-release"

  def published_at : Time
    Time.utc(year: 2020, month: 4, day: 13)
  end

  def summary : String
    <<-TEXT
    Lucky v0.20 has built-in pagination, AvramSlugify
    for generating slugs, built-in soft delete helpers, and much more.
    TEXT
  end

  def content : String
    <<-MD
    [Lucky v0.20](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md#changes-in-020)
    is out now and works with the newest version of Crystal (v0.34.0)

    Be sure to upgrade your version of Crystal, and take a look at our
    [UPGRADE NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-019-to-020)
    for help with migrating your app.

    > Note: this release has some warnings from Crystal 0.34. Don't worry,
    these warnings do not affect functionality and will be addressed in a
    release coming in the next couple weeks. Stay tuned!

    ## What's new?

    This release has tons of big new features, improvements, and bug fixes.
    You can see a detailed list on our [CHANGELOG](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md#changes-in-020).

    ### Built-in pagination

    Nearly every web application or API needs to paginate records, and it is
    now much easier with Lucky 0.20.

    The new `paginate` method in actions will paginate the query and return
    pagination metadata used to build page navigation.

    ```crystal
    class Users::Index < BrowserAction
      get "/users" do
        pages, users = paginate(UserQuery.new)
        html IndexPage, pages: pages, users: users
      end
    end
    ```

    Then use one of our [built-in HTML components](https://github.com/luckyframework/lucky/tree/main/src/lucky/paginator/components):

    ```crystal
    # Built-in components for Bulma, Bootstrap, and raw HTML
    mount Lucky::Paginator::BulmaNav.new(pages)
    ```

    > Don't worry, you can copy one of the
    > [built-in components](https://github.com/luckyframework/lucky/tree/main/src/lucky/paginator/components)
    > into your app and customize as much as you want!

    Or add metadata to API responses:

    ```crystal
    class Users::Index < BrowserAction
      get "/users" do
        pages, users = paginate(UserQuery.new)
        # Render pagination metadata
        response.headers["Next-Page"] = pages.path_for_next
        json UserSerializer.for_collection(users)
      end
    end
    ```

    See all the details and options in the new [pagination guide](#{Guides::Database::Pagination.path}).

    ### AvramSlugify

    Creating a slug for prettier URLs and permalinks is common in web applications.
    It's now easier than ever with the new official shard, [AvramSlugify](https://github.com/luckyframework/avram_slugify).

    ```
    class SaveArticle < Article::SaveOperation
      before_save do
        AvramSlugify.set slug,
          using: title,
          query: ArticleQuery.new
      end
    end
    ```

    This will set the column `slug` to a slugified version of the `title`,
    and check that the slug is unique using `ArticleQuery.new`.

    So if someone created a post with a title of `"Lucky rocks!"` the slug would be
    set to `"lucky-rocks"`. See full usage details in
    [the AvramSlugify README](https://github.com/luckyframework/avram_slugify).

    ### Soft delete

    Sometimes you don't want to actually delete a record right away, but
    instead want to "soft delete" it and stop showing it to users. This is a
    good safety mechanism and even allows you to later restore the record
    if you want it back.

    Here's a quick example:

    ```crystal
    comment = CommentQuery.first

    comment.soft_delete
    CommentQuery.new.only_kept.count # 0
    CommentQuery.new.only_soft_deleted.count # 1

    comment.restore
    CommentQuery.new.only_kept.count # 1
    CommentQuery.new.only_soft_deleted.count # 0
    ```

    Take a look at the
    [soft delete guide](#{Guides::Database::DeletingRecords.path(anchor: Guides::Database::DeletingRecords::ANCHOR_SOFT_DELETE)})
     to learn how to only show kept records by default, see other helpful
     methods, and learn how to set it up.

    ### New system_check script

    Lucky v0.20 now has a `script/system_check` that runs at the start of
    `script/setup` and whenever you start your dev server with `lucky dev`.

    It will make sure Postgres is up and running, and required dependencies
    are installed. You can modify this script to add your own system checks
    as well. For example, you can check that ElasticSearch is installed and running.

    Read all about it in the [script/system_check guide](#{Guides::GettingStarted::StartingProject.path(anchor: Guides::GettingStarted::StartingProject::ANCHOR_SYSTEM_CHECK)}).

    ## Parting words

    We're very excited about this release, and hope you are too. Please give it a spin and help
    us find bugs so our next release is even more solid. If you find any issues, don't hesitate
    to [report the issue](https://github.com/luckyframework/lucky/issues). If you're unsure, just
    hop on [gitter chat](https://gitter.im/luckyframework/Lobby) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [gitter](https://gitter.im/luckyframework/Lobby).
    MD
  end
end
