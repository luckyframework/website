class Guides::Frontend::Internationalization < GuideAction
  guide_route "/frontend/internationalization"

  def self.title
    "Internationalization"
  end

  def markdown : String
    <<-MD
    ## Working with multiple languages

    If these steps are done in order then Lucky should continue to compile (& be usable/testable) with each change.

    **Summary:**
    After configuration you can apply translations using either:
    ```crystal
    # simplest (requires user_lang or current_user to be defined)
    t("tranlation.key.values")

    # or wherever `current_user` is available
    I18n.t("tranlation.key.values", current_user.lang)
    ```

    > This document assumes you are using the default [Authentication](https://luckyframework.org/guides/authentication) - if not, you will need to make adjustments to the `user` in the Translator.

    ## Step 1 - Add i18n shard

    ```yaml
    dependencies:
      i18n:
        github: vladfaust/i18n.cr
        version: ~> 0.1.1
    ```

    Add to the end of `src/shards.cr` file with the new requirements:

    ```crystal
    # src/shards.cr
    # ...
    require "i18n"
    require "i18n/backends/yaml"
    ```

    and of course install the shard
    ```
    shards install
    ```

    ## Step 2 - Add localization ymls

    first make a locales folder:

    ```bash
    mkdir config/locales
    ```

    Then add at least one **default** localization: i.e. in this case English.  Below is a list of the starting keys in a standard LUCKY project with authorization and web pages.

    * Add additional langauges as needed in the same folder.  Language files need to be named with the `2-letter` language code (ISO 639-1) https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes - so the sample file is named `en.yml`
    * The yml file must start with it's langauge code, i.e. in this example `en:`  _(becareful, yml files are indentation sensitive)!_
    * Be sure that all lang yml files contain the same keys. If there's no translation for that key, just leave the value blank.  **If you miss a language key you will see an error message like: `MISSING: de.auth.sign_out`**

    > **NOTE:** If you missed a key and get the above error **YOU MUST RESTART LUCKY** to reload its config.

    ```yaml
    # config/locales/en.yml
    en:
      action:
        save_success: "The record has been saved"
        update_success: "The record has been updated"
        delete_success: "Deleted the record"
        index_title: "All Records"
        create_new: "New Record"
        new: New
        edit: Edit
        delete: Delete
        confirm: "Are you sure?"
        update: Update
        updating: "Updating..."
        save: Save
        saving: "Saving..."
        back: Back
        back_to_index: "Back to All"
      auth:
        sign_in: "Sign In"
        sign_in_success: "You're now signed in"
        sign_in_failure: "Sign in failed"
        sign_up: "Sign up"
        sign_up_success: "Thanks for signing up"
        sign_up_failure: "Couldn't sign you up"
        sign_out: "Sign Out"
        signed_out: "You have been signed out"
        pwd_update: "Update Password"
        pwd_update_success: "Your password has been reset"
        pwd_reset: "Password Reset"
        pwd_reset_request: "Reset your Password"
        pwd_reset_req_success: "You should receive an email on how to reset your password shortly"
      auth_token:
        not_authenticated: "Not Authenticated."
        invalid: "The provided authentication token was incorrect."
        missing: "An authentication token is required. Please include a token in an 'auth_token' param or 'Authorization' header."
      default:
        page_name: Welcome
      error:
        title: "Something went wrong"
        try_home: "Try heading back to home"
        locked_out: "Locked-out"
        auth_incorrect: "is wrong"
        form_not_valid: "It looks like the form is not valid"
        not_in_system: "is not in our system"
      user:
        email: E-Mail
        profile: Profile
        next: "Next, you may want to"
        auth_guides: "Check out the 'Authentication Guides'"
        modify_page: "Modify this page"
        after_signin: "Change where you go after sign in"
        preferred_language: "Preferred Language"
    ```

    ## Step 3 - Configure i18n within Lucky

    The i18n needs to know the location of your language files.
    > NOTE: This config file is only executed at load, so all language changes require a server restart.

    ```crystal
    # config/i18n.cr
    I18n.backend = I18n::Backends::YAML.new.tap do |backend|
      backend.load_paths << Dir.current + "/config/locales"
      backend.load
    end
    ```

    ## Step 4 - Add 'lang' to users table

    This setup will assocatiate a language key with each user this language key is used when displaying information.

    Generate a migration using:

    ```bash
    lucky gen.migration AddLanguageToUser
    ```

    Edit the new migration file in `db/migrations/`:

    ```crystal
    # db/migrations/#{Time.utc.to_s("%Y%m%d%H%I%S")}_add_language_to_user.cr
    class AddLanguageToUser::V20191228100116 < Avram::Migrator::Migration::V1
      def migrate
        alter table_for(User) do
          add lang : String, default: "en"  # the appropriate default lang key
        end
      end

      def rollback
        alter table_for(User) do
          remove :lang
        end
      end
    end
    ```

    Then run the migrations:

    ```bash
    lucky db.migrate
    ```

    ## Step 5 - Add lang column to User model

    ```crystal
    # src/models/user.cr
    class User < BaseModel
      # ...
      table do
        column lang : String
        # ...
      end
      # ...
    end
    ```

    ## Step 6 - Create a Translator module

    First create a location to extend your lucky system (at the top level is good if you have no other convention):

    ```bash
    $ touch src/translator.cr
    ```

    ```crystal
    # src/translator.cr
    module Translator
      LANGUAGE_DEFAULT = "en"
      LANGUAGES_AVAILABLE = ["en", "de"]
      LANGUAGES_SELECTOR_LIST = [{"English", "en"}, {"Deutsch", "de"}]

      def t(key : String)
        I18n.translate(key, user_lang)
      end

      def t(key : String, count : Int32)
        I18n.translate(key, user_lang, count)
      end

      # in places where current_user / user isn't available be sure to override this method with
      # `quick_def user_lang, LANGUAGE_DEFAULT`
      def user_lang
        current_user.try(&.lang) || LANGUAGE_DEFAULT
      end
    end
    ```

    Add this module to the `src/app.cr` so its available to Lucky files.
    > NOTE: Put this at the **top of this config file** to be sure it is available to all aspect of Lucky!

    ```crystal
    # src/app.cr
    require "./shards"

    # Load the asset manifest in public/mix-manifest.json
    Lucky::AssetHelpers.load_manifest

    require "./translator"
    # ...
    ```

    ## Step 7 - Update Operations

    SignUp Save Opoeration needs:
    - Update permitted columns (required for the signup form)
    - Update validations (will prevent run-time crashes)

    ```crystal
    # src/operations/sign_up_user.cr
    class SignUpUser < User::SaveOperation
      # ...
      permit_columns email, lang
      # ...
      before_save do
        # ...
        validate_inclusion_of lang, in: Translator::LANGUAGES_AVAILABLE
        # ...
      end
    end
    ```

    Other Operation Files with translations need:
    - Add `include Translator` to the class
    - Add `quick_def user_lang`, LANGUAGE_DEFAULT for the failure error messages (ok since happy path messages are handled in other paths)
    - Add translations: i.e. `t("translation.keys")`
      * in cases where there is no user in the entire class override `user_lang` with `quick_def user_lang, LANGUAGE_DEFAULT`
      * in cases where the user login failed (or something like that) you can translate using: `I18n.t("translation.keys", LANGUAGE_DEFAULT)` or override the `user_lang` locally with `user_lang = LANGUAGE_DEFAULT`

    > TODO: The translation module should use language settigns from the frontend (JS) first and fallback to the user or default setting.

    Thus SignIn would look like the situation with no user since the only messages it creates are when the login fails.

    ```crystal
    # src/operations/sign_in_user.cr
    class SignInUser < Avram::Operation
      # ...
      include Translator
      quick_def user_lang, LANGUAGE_DEFAULT
      # ...
      private def validate_credentials(user)
        if user
          unless Authentic.correct_password?(user, password.value.to_s)
            password.add_error t("error.auth_incorrect")
          end
        else
          # ...
          email.add_error t("error.not_in_system")
        end
      end
    end
    ```

    Similarly, RequestPasswordReset only messages when the user can't be found.

    ```crystal
    # src/operations/request_password_reset.cr
    class RequestPasswordReset < Avram::Operation
      # ...
      include Translator
      quick_def user_lang, LANGUAGE_DEFAULT
      # ...
      def validate(user : User?)
        # ...
        if user.nil?
          email.add_error t("error.not_in_system")
        end
      end
    end
    ```

    ## Step 8 - Internationalize Templates

    Basic ideas:
    - Every Layout (abstract class) needs the `include Translator`
    - Everywhere there is static text a translations can be added

    ```crystal
    # src/pages/main_layout.cr
    abstract class MainLayout
      include Translator
      # ...
      needs current_user : User
      # ...
      def page_title
        t("default.page_name")
      end

      def render
        # ...
        html lang: user_lang do
          # ...
        end
      end

      private def render_signed_in_user
        # ...
        link t("auth.sign_out"), to: SignIns::Delete, flow_id: "sign-out-button"
      end
    end
    ```

    AuthLayout needs updates and user_lang defined (since no user is available yet)

    ```crystal
    # src/pages/auth_layout.cr
    abstract class AuthLayout
      include Translator
      # ...
      # since user hasn't logged in yet - we set the user_lang to the default language
      quick_def user_lang, LANGUAGE_DEFAULT
      # ...
      def page_title
        t("default.page_name")
      end

      def render
        # ...
        html lang: user_lang do
          # ...
        end
      end
    end
    ```

    Error Show Page also additinally needs user_lang defined.

    ```crystal
    # src/pages/errors/show_page.cr
    class Errors::ShowPage
      # ...
      include Translator
      # ...
      # in error conditions we don't know if we have a current_user - so we use the default language
      quick_def user_lang, LANGUAGE_DEFAULT
      # ...
      def render
        # ...
        html lang: user_lang do
          # ...
          title t("error.title")
          # ...
        end
      end
      # ...
    end
    ```

    ## Step 9 - Update Sign-up Form

    Basic Idea:
    - Add translations
    - Add language choices to the sign-up form

    > You'll need to style the select to your tastes.

    ```crystal
    # src/pages/sign_ups/new_page.cr
    class SignUps::NewPage < AuthLayout
      # ...
      def content
        h1 t("auth.sign_up")
        # ...
      end

      private def render_sign_up_form(op)
        form_for SignUps::Create do
          # ...
          submit t("auth.sign_up"), flow_id: "sign-up-button"
        end
        link t("auth.sign_in"), to: SignIns::New
      end

      private def sign_up_fields(op)
        label_for op.lang, t("user.preferred_language")
        select_input(op.lang) do
          options_for_select(op.lang, LANGUAGES_SELECTOR_LIST)
        end
        # ...
      end
    end
    ```


    ## Step 10 - Internationalize Pages

    Add translations to the pages.

    ```crystal
    # src/pages/me/show_page.cr
    class Me::ShowPage < MainLayout
      def content
        h1 t("me.profile")
        h3 "\#{t("me.email")}: \#{@current_user.email}"
        # ...
      end

      private def helpful_tips
        h3 "\#{t("me.next")}:"
        ul do
          # ...
          li "\#{t("me.modify_page")}: src/pages/me/show_page.cr"
          li "\#{t("me.after_signin")}: src/actions/home/index.cr"
        end
      end

      private def link_to_authentication_guides
        a t("me.auth_guides"), href: "https://luckyframework.org/guides/authentication"
      end
    end
    ```

    Follow the same logic for the following files (as desired):

    ```
    # src/pages/password_reset_requests/new_page.cr
    # src/pages/password_resets/new_page.cr
    # src/pages/sign_ins/new_page.cr
    # src/pages/errors/show_page.cr
    ```

    ## Step 11 - Internationalize Actions

    Add `include Translator` to the abstract class BrowserAction - this allows translations in flash messages too.

    ```crystal
    # src/actions/browser_action.cr
    abstract class BrowserAction < Lucky::Action
      include Translator
      # ...
    end
    ```

    In these next two classes (Actions) there are cases where the user context may not be available - so assign `user_lang` to the `LANGUAGE_DEFAULT`)

    ```crystal
    # src/actions/sign_ins/create.cr
    class SignIns::Create < BrowserAction
      # ...
          if authenticated_user
            # ...
            flash.success = t("auth.success")
            # ...
          else
            # may be needed when user auth fails
            user_lang = LANGUAGE_DEFAULT
            flash.failure = t("auth.failure")
            # ...
          end
      # ...
    end
    ```

    And the same here:

    ```crystal
    # src/actions/sign_ups/create.cr
    class SignUps::Create < BrowserAction
      # ...
      post "/sign_up" do
        SignUpUser.create(params) do |operation, user|
          if user
            flash.success = t("auth.sign_up_success")
            # ...
          else
            # when user signup fails we need a language preference
            user_lang = LANGUAGE_DEFAULT
            flash.failure = t("auth.sign_up_failure")
            # ...
          end
        end
      end
    end
    ```

    With SignIns::Delete (Sign-out) - put the flash assignment first so it has the user conext before the user session is gone.

    ```crystal
    # src/actions/sign_ins/delete.cr
    class SignIns::Delete < BrowserAction
      delete "/sign_out" do
        # assign the flash before loosing the current_user
        flash.info = t("auth.signed_out")
        sign_out
        redirect to: SignIns::New
      end
    end
    ```

    Follow the same logic in these files:

    ```crystal
    # src/actions/password_resets/create.cr
    # src/actions/password_reset_requests/create.cr
    ```

    ## Step 12 - Internationalize API Responses

    If standard APIs responses need translation `include Translator` here:

    ```crystal
    # src/actions/api_action.cr
    abstract class ApiAction < Lucky::Action
      include Translator
      # ...
    end
    ```

    And here too for API Auth Responses

    ```crystal
    # src/actions/mixins/api/auth/require_auth_token.cr
    module Api::Auth::RequireAuthToken
      include Translator
      # ...
      private def auth_error_json
        # since we have no valid user define `user_lang`
        user_lang = LANGUAGE_DEFAULT
        ErrorSerializer.new(
          message: t("auth_token.not_authenticated"), details: auth_error_details
        )
      end

      private def auth_error_details : String
        # since we have no valid user define `user_lang`
        user_lang = LANGUAGE_DEFAULT
        if auth_token
          t("auth_token.invalid")
        else
          t("auth_token.missing")
        end
      end
      # ...
    end
    ```
    MD
  end
end
