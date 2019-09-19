class Guides::Authentication::Intro < GuideAction
  guide_route "/authentication"

  def self.title
    "Authentication Introduction"
  end

  def markdown
    <<-MD
    ## Overview

    When creating a new Lucky project you can choose to generate files for
    authentication with email and password.

    If you have an API only Lucky app, Lucky will generate operations,
    models, mixins, and actions for signing up and authenticating with an
    auth token (JWT).

    If you have the whole enchilada you will still get API auth, but also
    actions and pages for signing in, signing out, and resetting your
    password through the browser.

    ## Generated files

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

    ## Optional sign in

    By default Lucky assumes most pages require sign in (apps like Gmail,
    SalesForce, and Dropbox). To handle this the `Auth::RequireSignIn` module
    is included in the `BrowserAction`.

    Some apps have pages where guests can visit without sign in (Reddit, Twitter,
    ebay). If you have pages like that you'll need to make a couple changes:

    ### When the page looks very similar for signed out users

    Make `current_user` optional in the `MainLayout` (`src/pages/main_layout.cr`):

    ```crystal
    # From this
    needs current_user : User

    # To this
    needs current_user : User?
    ```

    In your actions that don't require sign in include the
    `Auth::SkipRequireSignIn` module:

    ```crystal
    class Users::Index < BrowserAction
      include Auth::SkipRequireSignIn

      # other code
    end
    ```

    To use the `current_user` in your pages you'll now need check if it is nil or not:

    ```crystal
    def content
      @current_user.try do |user|
        text user.email
      end

      # or if you need an else branch
      user = @current_user
      if user
        text "Signed in as: "
        text user.email
      else
        text "Not signed in!"
      end
    end
    ```

    ### When a page looks very different

    When pages look very different (different columns, sections, sidebars, etc.)
    it is usually best to extract a new layout.

    * First, Duplicate the `MainLayout` in `src/pages/main_layout.cr` and give it a new name.


    * Then, remove `needs current_user : User` from the new layout if this page is
      only for signed out users. If the page may have a signed in user make the
      `User` nilable: `needs current_user : User?`
    * If you remove `needs current_user` because the layout is *only for signed
      out users* then remember to include `Auth::RedirectIfSignedIn` in your actions
      so that the `current_user` is not exposed to the page. If the layout is for users
      that may or may not be signed in then include `Auth::AllowGuests` in
      the actions that do not require sign in.
    MD
  end
end
