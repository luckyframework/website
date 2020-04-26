class Guides::Authentication::Browser < GuideAction
  ANCHOR_ALLOW_GUESTS = "perma-allow-guests"
  guide_route "/authentication/browser"

  def self.title
    "Browser Authentication"
  end

  def markdown : String
    <<-MD
    ## Overview

    When a full Lucky app is generated with auth you will get:

    * Sign up
    * Sign in
    * Sign out
    * Password reset
    * Basic profile page

    ## Requiring sign in

    By default actions that inherit from `BrowserAction`
    (`src/actions/browser_action.cr`) will require sign in because
    `BrowserAction` includes the `Auth::RequireSignIn` module
    (`src/actions/mixins/auth/require_sign_in.cr`). This is a great way to
    make sure that your actions are protected by default.

    If your action requires sign in and you are rendering HTML, you will
    likely make the page you are rendering inherit from `MainLayout`. This is
    because `MainLayout` requires that a `current_user` is available.

    The next section talks about what to do when sign in is optional.

    #{permalink(ANCHOR_ALLOW_GUESTS)}
    ## Making sign in optional

    To allow guests (signed out users) to view an action, include the
    `Auth::AllowGuests` mixin in the action.

    ### Auth::AllowGuests mixin

    This will allow guests to request this action. It will also make the
    `current_user` method nilable (if no user is signed in `current_user` will return
    `nil`).

    ```crystal
    class PublicPosts < BrowserAction
      include Auth::AllowGuests
    end
    ```

    Now we have to figure out how to handle the possibility of a guest in our
    pages and layouts.

    ## Pages & layouts

    By default there are 2 layouts generated:

    * `AuthLayout`
    * `MainLayout`

    ### AuthLayout

    This is the layout that "auth" pages will use, such as
    `PasswordsResets::NewPage` or `SignUps::NewPage`. The `AuthLayout` does
    not need a `current_user` because these pages are meant to be used by
    guests that have not yet signed in/up.

    ### MainLayout

    This is the layout used for pages where a user has been signed in. It
    requires a `current_user` because it declares that it `needs current_user
    : User`.

    ```crystal
    abstract class MainLayout
      # 'needs current_user : User' makes it so that the current_user
      # is always required for pages using MainLayout
      needs current_user : User
    end
    ```

    ## Handle guests in pages & layouts

    There are a few options available when rendering a page for a guest user
    that has not signed in.

    * Use `AuthLayout` if the page is related to authentication.
    * Create a new layout.
    * Make changes to `MainLayout` to allow signed out users.

    ### Use AuthLayout

    If you have a page that you'd like to use for authentication it is probably
    best to use the `AuthLayout`. This could be useful for pages like
    adding 2 factor auth, social logins, etc.

    You can use this layout like any other layout:

    ```crystal
    class TwoFactorAuth::NewPage < AuthLayout
    end
    ```

    ### Create a new layout

    This is usually the best option because you can keep the `MainLayout` for
    signed in users, and a new layout for things like marketing pages, and
    other public pages.

    For example, if you want to add some marketing pages you could create a
    `MarketingLayout` that either does not need a signed in user, or accepts
    signed in users and guests.

    ```crystal
    abstract class MarketingLayout
      include Lucky::HTMLPage

      # You may want to add 'needs current_user : User?'
      #
      # This might be useful if you want to show a "Go to app" button in the
      # header if current_user is already signed in.
      #
      # needs current_user : User?
    end
    ```

    Some other ideas for naming layouts:

    * `PublicLayout`
    * `GuestLayout`
    * `SupportLayout`

    ### Change MainLayout to allow signed out users

    This might be a good option if you are building an app where the pages
    are **available to both guests and signed in users**. For example, Reddit
    allows signed in users and guests (signed out users) to view most pages.

    If this is the type of page you want to build, you can change the `needs
    current_user` in `MainLayout` to allow `nil`:

    ```crystal
    # src/pages/main_layout.cr
    abstract class MainLayout
      # Append '?' to make it so current_user can be 'nil'
      needs current_user : User?
    end
    ```

    You will also need to check if the `current_user` is present in a few places.
    For example in `MainLayout` you'll have to change where the signed in user
    is displayed in the header.

    Add conditional to `MainLayout#render_signed_in_user`:

    ```crystal
    private def render_signed_in_user
      user = @current_user

      if user
        text user.email
        text " - "
        link "Sign out", to: SignIns::Delete, flow_id: "sign-out-button"
      end
    end
    ```

    ### Inherit from MainLayout

    You can now make pages that inherit from this layout and they will work
    for signed in users and guests.

    Your action might look like this:

    ```crystal
    class Posts::Index < BrowserAction
      include Auth::AllowGuests

      route do
        html Posts::IndexPage, posts: PostQuery.new
      end
    end
    ```

    And the page might look like this:

    ```crystal
    class Posts::IndexPage < MainLayout
      needs posts : PostQuery

      def content
        # html the page contents
      end
    end
    ```

    Note that **you can still use this layout for actions that require sign in**,
    but you will need to check for the signed in user before displaying anything
    that needs the current user.

    Let's say we have this action that requires sign in:

    ```crystal
    class Settings::Edit < BrowserAction
      route do
        html Settings::EditPage
      end
    end
    ```

    This will not work because `@current_user` might be nil:

    ```crystal
    class Settings::EditPage < MainLayout
      def content
        h1 "\#{@current_user.name}'s Settings'"
      end
    end
    ```

    **Instead you need to either check that the current_user is really there**,
    or since this page is used for actions that require sign in you could add
    a method that tells Crystal it is not nil:

    We'll use [`getter!`](https://crystal-lang.org/api/0.30.1/Object.html#getter!(*names)-macro)
    so that Crystal treats `current_user` as not nil.

    ```crystal
    class Settings::EditPage < MainLayout
      # Defines a getter that says current_user can't be nil
      getter! current_user

      def content
        # Use the 'current_user' method
        h1 "\#{current_user.name}'s Settings'"
      end
    end
    ```

    This works, but please note that if you accidentally use this page with
    an action that allows guests, you will get a runtime error because it
    will try to get the current_user's name, but the current_user will be
    `nil` for guests.

    Instead, **we recommend creating a new layout just for signed in users in cases like
    this**. It will catch more bugs and you won't have as much conditional logic.
    You can share common HTML across layouts with
    [components](#{Guides::Frontend::RenderingHtml.path(anchor: Guides::Frontend::RenderingHtml::ANCHOR_COMPONENTS)}).
    MD
  end
end
