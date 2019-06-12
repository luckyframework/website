class IntroducingTheLuckyBlog < BasePost
  title "Introducing Lucky 0.15 and a brand new website to go with it."
  slug "introducing-lucky-website"

  def published_at
    Time.utc(year: 2019, month: 6, day: 12)
  end

  def summary
    <<-TEXT
    Lucky v0.15 is a big new release. Brand new class based UI components,
    lots of bug fixes, and support for Crystal 0.29. We are also releasing a
    brand new website to go with it.
    TEXT
  end

  def content
    <<-MD
    Lucky 0.15.0 has been in the making for a few months and has lots of new
    goodies, bug fixes, and support for the newest version of Crystal (0.29.0)

    We're also releasing a brand new website along with this new version of Lucky.

    ## New website

    We've totally revamped the Lucky website. Check it out:

    * The new website is mobile friendly.
    * It has a blog (this one!).
    * You can [subscribe to hear about new updates](#{Blog::Index.path}).
    * Redesigned and rewritten [home page](#{Home::Index.path}).
    * [Rewritten and redesigned guides](#{Guides::GettingStarted::Installing.path})

    And the new website uses Lucky instead of Middleman 🎉

    ## Lucky 0.15

    Lucky 0.15 of bug fixes and improvements. We'd like to
    highlight a few of our favorite new features.

    ### New class based components

    You can now use classes for components. You declare what the component needs
    and then you can mount it on a page.

    This greatly simplifies code reuse, allows you to have named private methods,
    and makes testing a breeze

    ```crystal
    # lucky gen.component UserRow
    class UserRow < BaseComponent
      needs user : User

      def render
        div class: "user-row-style" do
          h2 @user.name
        end
      end
    end
    ```

    Now we can use it in a page with `mount`:

    ```crystal
    mount UserRow.new(UserQuery.first)
    ```

    Or test it by rendering the component to a string:

    ```crystal
    user = UserQuery.first
    html = UserRow.new(user.first).render_to_string
    html.should contain user.name
    ```

    ### New built-in security features

    There are now a bunch of new security headers that you can easily add and
    configure for your app. Check it out under our new
    [security guide](#{Guides::HttpAndRouting::SecurityHeaders.path}).

    ### Asset host for CDN

    You can configure an asset host for asset paths. This makes it simple to use
    your CDN for fast content delivery.

    ```crystal
    Lucky::Server.configure do |settings|
      if Lucky::Env.production?
        settings.asset_host = "https://myfastcdn.com"
      else
        settings.asset_host = "/"
      end
    end
    ```

    ## New goodies in Avram (Lucky's ORM)

    ### Introducing `nilable_eq`

    Previously you could pass a `nil` value when comparing values in a query.
    The problem with this is that you may not be expecting to compare to `nil`.

    Now Lucky helps make this distinction clear by only allowing `eq` for non-nil values
    and using `nilable_eq` for things that may be `nil`. This will help catch subtle nil bugs.

    ```crystal
    # 'name' might be a String or Nil
    name = ["John", nil].sample

    # When using 'eq' Lucky will stop at compile time and tell
    # you that you are comparing to a possible 'nil' value
    UserQuery.new.name.eq(name)
    ```

    We can make this work by using `nilable_eq` or handling the `nil` with
    a conditional

    ```crystal
    name = ["John", nil].sample
    UserQuery.new.name.nilable_eq(name)

    # Or if we want to handle 'nil' differently
    if name
      UserQuery.new.name.eq(name)
    else
      raise "Oh no! There is no name"
    end
    ```

    ### Easily generate unique data for tests

    Avram Boxes are how we generate test data. This release introduces `sequence`
    for easily generating unique values.

    ```crystal
    class UserBox < Avram::Box
      def initialize
        # username-1, username-2, etc.
        username sequence("username")
        # email-1@example.com, email-2@example.com, etc.
        email "\#{sequence("email")}@example.com"
      end
    end
    ```

    ## Lots of other bug fixes and improvements

    There are lots of other improvements and bug fixes in this release. Thanks
    to all our contributors that made this release possible!

    We hope you love it!
    MD
  end
end
