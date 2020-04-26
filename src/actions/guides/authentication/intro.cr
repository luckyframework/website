class Guides::Authentication::Intro < GuideAction
  guide_route "/authentication"

  def self.title
    "Authentication Introduction"
  end

  def markdown : String
    <<-MD
    ## Overview

    When creating a new Lucky project you can choose to generate files for
    authentication with email and password.

    **If you have an API only Lucky app**, Lucky will generate operations,
    models, mixins, and actions for signing up and authenticating with an
    auth token (JWT).

    **If you have a full Lucky app** you will still get API auth, but also
    actions and pages for signing in, signing out, and resetting your
    password through the browser.

    ## Retrieving the signed in user

    There are in depth guides on [authentication with HTML pages](#{Guides::Authentication::Browser.path})
    and [APIs](#{Guides::Authentication::Api.path}), but here
    are some quick examples of working with the signed in user.

    ### Get the signed in user

    To get the currently signed in user, call `current_user` in your actions.
    If your action requires sign in, `current_user` will always return a `User`
    and never `nil`. If sign in is
    [optional](#{Guides::Authentication::Browser.path(anchor: Guides::Authentication::Browser::ANCHOR_ALLOW_GUESTS)})
    then `current_user` may be `nil`.

    In HTML pages using the `MainLayout` you can get the signed in user with
    `@current_user`.

    ### When current user might be nil

    If the current user might be `nil` by
    [allowing guests](#{Guides::Authentication::Browser.path(anchor: Guides::Authentication::Browser::ANCHOR_ALLOW_GUESTS)})
    or [skipping the auth token](#{Guides::Authentication::Api.path(anchor: Guides::Authentication::Api::ANCHOR_OPTIONAL_TOKEN)})
    you need to use a conditional before using `current_user`

    ```crystal
    class Hello::Show < BrowserAction
      # This will allow users that are not signed in
      include Auth::AllowGuests

      route do
        user = current_user

        # Check if user is signed in
        if user
          plain_text "Hello \#{user.name}"
        else
          plain_text "Hello!"
        end
      end
    end
    ```

    This works because Crystal will ensure a variable isn't nil when you use
    an `if` statement. Read more about how Crystal handles `if`
    [here](https://crystal-lang.org/reference/syntax_and_semantics/if_var.html)

    ### Associating database records with the current user

    Let's say we have an `Article` model with a `title : String` and `belongs_to author : User`.

    To create the article and associate it the signed in user, do this:

    ```crystal
    class Articles::Create < BrowserAction
      route do
        # Set 'author_id' to the current_user's id
        SaveArticle.create!(params, author_id: current_user.id) do |op, article|
          # ...
        end
      end
    end
    ```

    ### Filter records by current_user

    If we only want to return articles for the signed in user. We
    can do it like this:

    ```crystal
    class MyArticles::Index < BrowserAction
      route do
        # Filter articles by 'author_id'
        articles = ArticleQuery.new.author_id(current_user.id)
        html MyArticles::IndexPage, articles: articles
      end
    end
    ```

    ## Generated files

    These are the files generated with `lucky init` with auth.

    ### Browser Actions (not in API only apps)

    * `src/actions/browser_action.cr` - includes mixins for checking sign in, getting current user, and signing users in using cookies.
    * `src/actions/home/index.cr` - redirects users based on whether signed in/out.
    * `src/actions/me/show.cr` - the current user's profile.
    * `src/actions/sign_ins/*`
    * `src/actions/sign_ups/*`
    * `src/actions/sign_outs/*`
    * `src/actions/password_resets/*`
    * `src/actions/password_reset_requests/*`
    * `src/actions/mixins/auth/*` - mixins for requiring sign in, skipping sign in, etc.
    * `src/actions/mixins/password_resets/*` - mixins for working with password resets.

    ### API Actions

    * `src/actions/mixins/api/auth/*` - mixins for checking sign in, getting current user, and signing users in with a token.
    * `src/actions/api_action.cr` - includes mixins for token auth.
    * `src/actions/api/sign_ins/*` - generate a token for the user.
    * `src/actions/api/sign_ups/*`
    * `src/actions/api/me/show.cr` - the currently signed in user as JSON.

    ### Operations

    * `src/operations/mixins/password_validations.cr` - mixin used in the `SignUpUser`
      and `ResetPassword` so password validations are the same in both.
    * `src/operations/sign_up_user.cr`
    * `src/operations/sign_in_user.cr`
    * `src/operations/request_password_reset.cr` - not in API only apps.
    * `src/operations/reset_password.cr` - not in API only apps.

    ### Serializers

    * `src/serializers/user_serializer.cr`

    ### Pages & Layouts (not in API only apps)

    * `src/pages/main_layout.cr` - this layout requires a sign in user.
    * `src/pages/auth_layout.cr` - this layout is used by the auth pages (sign
      in, sign up, password reset) and does not require or have access to the `current_user`.
    * `src/pages/sign_ups/*`
    * `src/pages/sign_ins/*`
    * `src/pages/request_password_resets/*`
    * `src/pages/password_resets/*`
    * `src/pages/me/show_page.cr`

    ### Model, migration, and query:

    * `db/migrations/00000000000001_create_users.cr` - create the initial users table
    * `src/models/user.cr`
    * `src/queries/user_query.cr`
    MD
  end
end
