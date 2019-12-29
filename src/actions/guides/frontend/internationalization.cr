class Guides::Frontend::Internationalization < GuideAction
  guide_route "/frontend/internationalization"

  def self.title
    "Internationalization"
  end

  def markdown : String
    <<-MD
    **Working with multiple languages**

    If these steps are done in oder then Lucky should continue to compile (& be usable/testable) with each change.

    ## Step 0 - Add i18n shard

    ```
    dependencies:
      i18n:
        github: vladfaust/i18n.cr
        version: ~> 0.1.1
    ```

    add to the end of `shards.cr` file with the new requirements
    ```
    # shards.cr
    # ...
    require "i18n"
    require "i18n/backends/yaml"
    ```

    and of course install the shard
    ```
    shards install
    ```

    ## Step 1 - Add localization ymls

    first make a locales folder:
    ```
    mkdir config/locales
    ```

    then add at least one localization: i.e. English (here is a list of the fixed text - excluding the ones missed)
    ```
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

    - add additional langauges as needed in the same folder.
    - i18n is very unforgiving with yml files and the error messages aren't helpful.  If you have problem - be sure to use an online yml validator,

    **NOTE:** All lang yml files need all the same keys defined!

    ## Step 2 - Configure i18n within Lucky
    ```
    # config/i18n.cr
    I18n.backend = I18n::Backends::YAML.new.tap do |backend|
      backend.load_paths << Dir.current + "/config/locales"
      backend.load
    end
    ```

    ## Step 3 - Add 'lang' to users table

    generate a migration using:
    ```
    lucky db.migration AddLanguageToUser
    ```

    edit the file to look like (of course, the number will vary):
    ```
    # db/migrations/20191228100116_add_language_to_user.cr
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

    and of course migrate
    ```
    lucky db.migrate
    ```

    ## Step 4 - Add lang column to User model
    ```
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

    ## Step 5 - Create a Translator module

    TODO:
    - finalize the best approach & ideally be ready to capture any Frontend JS overrides
    - autodect and autocreate the language list based on the config/locales yml files.

    ```
    # src/translator.cr
    module Translator

      DEFAULT_LANGUAGE = "en"
      AVAILABLE_LANGUAGES = ["en", "de"]

      def t(key : String)
        I18n.translate(key, user_lang)
      end

      def t(key : String, count : Int32)
        I18n.translate(key, user_lang, count)
      end

      def user_lang(current_user=nil)
        current_user.try(&.lang) || DEFAULT_LANGUAGE
      end
    end
    ```

    and include in `src/app.cr` (isn't effect yet)
    ```
    # src/app.cr
    # ...
    require "./translate"
    ```

    ## Step 6 - Update Operations (espescially `sign_up_user`)

    General Operations Tasks:
    - add `require "../translator"` at the top of the file
    - add `include Translator` to the class
    - add translations, i.e.: email.add_error t("error.not_our_system")

    Also necessary for sign_up_user operation:
    - update permitted columns (required for the signup form)
    - update validations (will prevent run-time crashes)

    ```
    # src/operations/sign_up_user.cr
    require "../translator"

    class SignUpUser < User::SaveOperation
      include Translator
      # ...
      permit_columns email, lang
      # ...
      before_save do
        # ...
        validate_inclusion_of lang, in: AVAILABLE_LANGUAGES
        # ...
      end
    end
    ```

    other operations with fixed messages include:
    ```
    # src/operations/request_password_reset.cr
    # src/operations/sign_in_user.cr
    # src/operations/sign_up_user.cr
    ```

    ## Step 7 - Internationalize Templates

    This is required before doing the `concrete classes`

    Basic ideas:
    - every Layout (abstract class) needs the Translator included.
    - everywhere there is static text a translations can be added with: `t("primary_key.sub_key")` - keys can be nested arbritrarily deep.
    ```
    require "../translator"

    abstract class MainLayout
      include Translator
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

    ```
    # src/pages/auth_layout.cr
    require "../translator"

    abstract class AuthLayout
      include Translator
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

    error page also need tranlation import (separately)
    ```
    # src/pages/errors/show_page.cr
    require "../../translator"

    class Errors::ShowPage
      include Lucky::HTMLPage
      include Translator
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

    ## Step 8 - Internationalize Pages

    **IMPORTANT:** start with and test the signup page so that users can choose the language of their choice

    Basic Idea:
    - add translations
    - add dropdown menu of language choices
    - this step requires `permit_columns` in `src/operations/sign_up_user.cr`

    **You'll need to style the select to your tastes - the default is UGLY!**
    ```
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

    Here is a more complex example of combining messages with other text info (urls).
    ```
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
        link t("me.auth_guides"), to: "https://luckyframework.org/guides/authentication"
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

    ## Step 9 - Internationalize Flash Messages & Actions

    ```
    # src/actions/browser_action.cr
    require "../translator"

    abstract class BrowserAction < Lucky::Action
      include Translator
      # ...
    end
    ```

    now in actions you can use translations in actions:
    ```
    # src/actions/sign_ins/create.cr
    class SignIns::Create < BrowserAction
      # ...
          if authenticated_user
            # ...
            flash.success = t("auth.success")
            # ...
          else
            flash.failure = t("auth.failure")
            # ...
          end
      # ...
    end
    ```

    Follow the same logic in the following files:
    ```
    # src/actions/sign_ins/delete.cr
    # src/actions/sign_ups/create.cr
    # src/actions/password_resets/create.cr
    # src/actions/password_reset_requests/create.cr
    ```

    Step 10: - Internationalize API Responses

    Given the deep namespace for the API - the require statement is a bit clumsy looking but works.
    ```
    # src/actions/mixins/api/auth/require_auth_token.cr
    require "../../../../translator"

    module Api::Auth::RequireAuthToken
      include Translator
      # ...
      private def auth_error_json
        ErrorSerializer.new(
          message: t("auth_token.not_authenticated"),
          details: auth_error_details
        )
      end

      private def auth_error_details : String
        if auth_token
          t("auth_token.invalid")
        else
          t("auth_token.invalid")
        end
      end
      # ...
    end
    ```

    _Thanks to @paulcsmith & @bdtomlin and others for helping and guiding this document._
    MD
  end
end
