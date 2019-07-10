class Guides::Authentication::Show < GuideAction
  guide_route "/authentication"

  def self.title
    "Authentication"
  end

  def markdown
    <<-MD
    ## Generated file locations

    By default Lucky generates files for authentication with email and password.
    Actions require sign in by default (set in `BrowserAction`), but can be
    configured differently by modifying these files. You can also remove feature
    by removing the folders. For example if you don't want to allow sign up
    (maybe users are added manually or through an API), you can remove the
    sign_ups actions, pages, and forms

    Actions and action mixins:

    * `src/actions/mixins/auth/*` - mixins for requiring sign in, skipping sign in, etc.
    * `src/actions/mixins/password_resets/*` - mixins for working with password resets.
    * `src/actions/browser_action.cr` - this is where the authentication methods are included
    * `src/actions/home/index.cr` - handles what to do when a user hits the home page and is signed in or not
    * `src/actions/sign_ups/*`
    * `src/actions/sign_ins/*`
    * `src/actions/sign_outs/*`
    * `src/actions/password_resets/*`
    * `src/actions/password_reset_requests/*`

    Forms:

    * `src/forms/mixins/password_validations.cr` - mixin used in the `SignUpForm`
      and `PasswordResetForm` so password validations are the same in both
    * `src/forms/sign_up_form.cr`
    * `src/forms/sign_in_form.cr`
    * `src/forms/password_reset_request_form.cr`
    * `src/forms/password_reset_form.cr`

    Pages & Layouts:

    * `src/pages/main_layout.cr`
    * `src/pages/guest_layout.cr` - this layout is used by the auth pages and does
      not require or have access to the `current_user`.
    * `src/pages/sign_ups/*`
    * `src/pages/sign_ins/*`
    * `src/pages/sign_outs/*`

    Model, migration, and query:

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
