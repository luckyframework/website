class Guides::Frontend::Internationalization < GuideAction
  guide_route "/frontend/internationalization"

  def self.title
    "Internationalization"
  end

  def markdown : String
    <<-MD
    ## Working with multiple languages

    If these steps are done in order then Lucky should continue to compile and
    be usable with each change.

    > We'll be using the [Rosetta shard](https://wout.github.io/rosetta/v0.3.0/)
    > because it integrates well with Lucky, it handles key lookup at
    > compile-time and it is very fast.

    **Summary:**

    After configuration you can apply translations using either:

    ```crystal
    r("tranlation.key.values").t
    ```

    Or wherever you'd want to use a specific language:

    ```crystal
    Rosetta.with_locale(current_user.language) do
      r("tranlation.key.values").t
    end
    ```

    > This document assumes you are using the default
    > [Authentication](https://luckyframework.org/guides/authentication) - if
    > not, you will need to make adjustments accordingly.

    ## Step 1 - Add the Rosetta shard

    ```yaml
    dependencies:
      rosetta:
        github: wout/rosetta
    ```

    Require the shard in `src/shards.cr`:

    ```crystal
    # src/shards.cr
    # ...
    require "rosetta"
    ```

    And of course, install the shard:

    ```
    shards install
    ```

    ## Step 2 - Configure Rosetta

    After installing, run the init command to have Rosetta set up the required
    files:

    ```bash
    bin/rosetta --init
    ```

    This will geneate:

    **1. An initializer at `config/rosetta.cr` with the following content:**

    ```crystal
    Rosetta::DEFAULT_LOCALE = :en
    Rosetta::AVAILABLE_LOCALES = %i[en]
    Rosetta::Backend.load("config/rosetta")
    ```

    Rosetta includes an integration macro for Lucky to include the
    `Rosetta::Translatable` module everywhere translations are needed. Add the
    following line at the bottom of `config/rosetta.cr` and you're good to go:

    ```crystal
    # ...
    Rosetta::Lucky.integrate
    ```

    **2. `config/rosetta/rosetta.en.yml`**

    This file contains localizations required by Rosetta. For every additional
    locale, you'll need to copy and translate this file.

    **3. `config/locales/example.en.yml`**

    An example locale file. Replace the contents of this file with the following
    to make it through this tutorial without compilation errors:

    ```yaml
    en:
      api:
        auth:
          not_authenticated: "Not authenticated."
          token_invalid: "The provided authentication token was incorrect."
          token_missing: |
            An authentication token is required. Please include a token in an 'auth_token' param or 'Authorization' header.
      default:
        button:
          sign_out: "Sign out"
          sign_up: "Sign up"
        error:
          incorrect_password: "is wrong"
          invalid_email: "is not in our system"
        field:
          email: "Email"
          language: "Language"
          password: "Password"
          password_confirmation: "Confirm password"
      errors:
        show_page:
          helpful_link: "Try heading back to home"
          page_title: "Something went wrong"
      me:
        show_page:
          after_signin: "Change where you go after sign in: src/actions/home/index.cr"
          auth_guides: "Check out the authentication guides"
          modify_page: "Modify this page: src/pages/me/show_page.cr"
          next_you_may_want_to: "Next, you may want to:"
          page_title: "This is your profile"
          user_email: "Email: %{email}"
      password_reset_requests:
        new_page:
          page_title: "Request password reset"
      password_resets:
        new_page:
          page_title: "Reset password"
      sign_ups:
        create:
          success: "Thanks for signing up"
          failure: "Couldn't sign you up"
        new_page:
          page_title: "Sign up"
          sign_in_instead: "Sign in instead"
      sign_ins:
        create:
          failure: "Sign in failed"
          success: "You're now signed in"
        delete:
          success: "You have been signed out"
        new_page:
          page_title: "Sign in"
    ```

    ## Step 3 - Add language to the users table

    This setup will associate a language key with each user. Generate a
    migration using:

    ```bash
    lucky gen.migration AddLanguageToUser
    ```

    Edit the new migration file in `db/migrations/`:

    ```crystal
    # db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_language_to_user.cr
    class AddLanguageToUser::V#{Time.utc.to_s("%Y%m%d%H%I%S")} < Avram::Migrator::Migration::V1
      def migrate
        alter table_for(User) do
          add language : String, default: "en"
        end
      end

      def rollback
        alter table_for(User) do
          remove :language
        end
      end
    end
    ```

    Then run the migrations:

    ```bash
    lucky db.migrate
    ```

    ## Step 4 - Add language column to User model

    ```crystal
    # src/models/user.cr
    class User < BaseModel
      # ...
      table do
        column language : String
        # ...
      end
      # ...
    end
    ```

    ## Step 5 - Add a before pipe to your actions

    Create a new file at `actions/mixins/set_language.cr` with the following
    content:

    ```crystal
    module SetLanguage
      macro included
        before set_language
      end

      private def set_language
        if language = current_user.try(&.language) || params.get?(:language)
          Rosetta.locale = language
        end

        continue
      end
    end
    ```

    And include it in your `BrowserAction`:

    ```crystal
    # src/actions/browser_action.cr
    abstract class BrowserAction < Lucky::Action
      # ...
      # Set the current language
      include SetLanguage
      # ...
    end
    ```

    This module tries to set `current_user`'s language. If there isn't a
    signed-in user, it tries to find a `language` query parameter. If both
    aren't present, the `Rosetta::DEFAULT_LOCALE` will be used, as configured in
    Rosetta's initializer (`config/rosetta.cr`).

    ## Step 6 - Update Operations

    The `SignUpUser` operation needs some changes:
    - Update permitted columns (required for the signup form)
    - Update validations (will prevent run-time crashes)

    ```crystal
    # src/operations/sign_up_user.cr
    class SignUpUser < User::SaveOperation
      # ...
      permit_columns email, language
      # ...
      before_save do
        # ...
        validate_inclusion_of language, in: Rosetta::AVAILABLE_LOCALES.map(&.to_s)
        # ...
      end
    end
    ```

    Make the error messages translatable in the `SignInUser` operation:

    ```crystal
    # src/operations/sign_in_user.cr
    class SignInUser < Avram::Operation
      private def validate_credentials(user)
        if user
          unless Authentic.correct_password?(user, password.value.to_s)
            password.add_error r("default.error.incorrect_password").t
          end
        else
          # ...
          email.add_error r("default.error.invalid_email").t
        end
      end
    end
    ```

    And do the same for the `RequestPasswordReset` operation:

    ```crystal
    # src/operations/request_password_reset.cr
    class RequestPasswordReset < Avram::Operation
      def validate(user : User?)
        # ...
        if user.nil?
          email.add_error r("default.error.invalid_email").t
        end
      end
    end
    ```

    ## Step 7 - Internationalize Templates

    Basic ideas:
    - Use `Rosetta.locale` to define `lang` attributes of the HTML document
    - Everywhere there is static text, a translation can be added

    ```crystal
    # src/pages/main_layout.cr
    abstract class MainLayout
      needs current_user : User
      # ...
      def page_title
        r(".page_title").t
      end

      def render
        # ...
        html lang: Rosetta.locale do
          # ...
        end
      end

      private def render_signed_in_user
        # ...
        link r("default.button.sign_out"), to: SignIns::Delete, flow_id: "sign-out-button"
      end
    end
    ```

    > **Note**: the locale key for `page_title` starts with a `.` to tell
    > Rosetta the prefix for this key should be derived from the current class.
    > For example, in the `Me::ShowPage`, the locale key will resolve to
    > `me.show_page.page_title`. It's an easy way to avoid having to define a
    > `page_title` method for every single page.

    > **Note 2**: when translating the link with `r("default.button.sign_out")`,
    > the `.t` method isn't called. That's because the returned value of the `r`
    > macro includes `Lucky::AllowedInTags`, so it's translated implicitly.

    Do the same for `AuthLayout`:

    ```crystal
    # src/pages/auth_layout.cr
    abstract class AuthLayout
      # ...
      def page_title
        r(".page_name").t
      end

      def render
        # ...
        html lang: Rosetta.locale do
          # ...
        end
      end
    end
    ```

    And the `Error::ShowPage`:

    ```crystal
    # src/pages/errors/show_page.cr
    class Errors::ShowPage
      def render
        # ...
        html lang: Rosetta.locale do
          # ...
          title r(".page_title")
          # ...
        end

        body do
          div class: "container" do
            #..
            ul class: "helpful-links" do
              li do
                a r(".helpful_link"), href: "/", class: "helpful-link"
              end
            end
          end
        end
      end
      # ...
    end
    ```

    ## Step 8 - Update Sign-up Form

    Basic Idea:
    - Add translations
    - Add language choices to the sign-up form

    > You'll need to style the select to your taste.

    ```crystal
    # src/pages/sign_ups/new_page.cr
    class SignUps::NewPage < AuthLayout
      # ...
      def content
        h1 r(".page_title")
        # ...
      end

      private def render_sign_up_form(op)
        form_for SignUps::Create do
          # ...
          submit r("default.button.sign_up").t, flow_id: "sign-up-button"
        end
        link r(".sign_in_instead"), to: SignIns::New
      end

      private def sign_up_fields(op)
        mount Shared::Field,
          attribute: op.email,
          label_text: r("default.field.email").t, &.email_input(autofocus: "true")
        mount Shared::Field,
          attribute: op.password,
          label_text: r("default.field.password").t, &.password_input
        mount Shared::Field,
          attribute: op.password_confirmation,
          label_text: r("default.field.password_confirmation").t, &.password_input
        mount Shared::Field,
          attribute: op.language,
          label_text: r("default.field.language").t, &.select_input do
          options_for_select(op.language, [{"English", "en"}])
        end
      end
    end
    ```

    ## Step 9 - Internationalize Pages

    Add translations to the pages.

    ```crystal
    # src/pages/me/show_page.cr
    class Me::ShowPage < MainLayout
      def content
        h1 r(".page_title")
        h3 r(".user_email").t(email: @current_user.email)
        # ...
      end

      private def helpful_tips
        h3 r(".next_you_may_want_to")
        ul do
          # ...
          li r(".modify_page")
          li r(".after_signin")
        end
      end

      private def link_to_authentication_guides
        a r(".auth_guides"), href: "https://luckyframework.org/guides/authentication"
      end
    end
    ```

    > **Note**: The `t` method for the `r(".user_email")` translation takes an
    > `email` argument. If a translation includes interpolation keys (in this
    > case `%{email}`), Rosetta will require an argument with the same name.

    Follow the same logic for the following files (as desired):

    ```
    # src/pages/password_reset_requests/new_page.cr
    # src/pages/password_resets/new_page.cr
    # src/pages/sign_ins/new_page.cr
    # src/pages/errors/show_page.cr
    ```

    ## Step 10 - Internationalize Actions

    Translate flash messages.

    ```crystal
    # src/actions/sign_ins/create.cr
    class SignIns::Create < BrowserAction
      # ...
          if authenticated_user
            # ...
            flash.success = r(".success").t
            # ...
          else
            flash.failure = r(".failure").t
            # ...
          end
      # ...
    end
    ```

    The same here:

    ```crystal
    # src/actions/sign_ups/create.cr
    class SignUps::Create < BrowserAction
      # ...
      post "/sign_up" do
        SignUpUser.create(params) do |operation, user|
          if user
            flash.success = r(".success").t
            # ...
          else
            flash.failure = r(".failure").t
            # ...
          end
        end
      end
    end
    ```

    And here:

    ```crystal
    # src/actions/sign_ins/delete.cr
    class SignIns::Delete < BrowserAction
      delete "/sign_out" do
        sign_out
        flash.info = r(".success").t
        redirect to: SignIns::New
      end
    end
    ```

    Follow the same logic in these files:

    ```crystal
    # src/actions/password_resets/create.cr
    # src/actions/password_reset_requests/create.cr
    ```

    ## Step 11 - Internationalize API Responses

    Similar to all previous steps, replace all untranslated strings:

    ```crystal
    # src/actions/mixins/api/auth/require_auth_token.cr
    module Api::Auth::RequireAuthToken
      private def auth_error_json
        ErrorSerializer.new(
          message: r("api.auth.not_authenticated").t,
          details: auth_error_details
        )
      end

      private def auth_error_details : String
        if auth_token
          r("api.auth.token_invalid").t
        else
          r("api.auth.token_missing").t
        end
      end
      # ...
    end
    ```
    MD
  end
end
