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

    then add at least one localization: i.e. English
    ```
    # config/locales/en.yml
    en:
      action:
        form_error: "It looks like the form is not valid"
        save_success: "The record has been saved"
        update_success: "The record has been updated"
        delete_success: "Deleted the record"
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
        pwd_reset_request: "Reset Password"
        pwd_reset_req_success: "You should receive an email on how to reset your password shortly"
      auth_token:
        not_authenticated: "Not Authenticated."
        invalid: "The provided authentication token was incorrect."
        missing: "An authentication token is required. Please include a token in an 'auth_token' param or 'Authorization' header."
      default:
        page_name: Welcome
      me:
        email: E-Mail
        profile: Profile
        next: "Next, you may want to"
        auth_guides: "Check out the 'Authentication Guides'"
        modify_page: "Modify this page"
        after_signin: "Change where you go after sign in"
    ```

    and for example additional ones as needed: i.e. German
    ```
    # config/locales/de.yml
    de:
      action:
        form_error: "Der Form ist Invalid"
        save_success: "Speichern Erfolgreich"
        update_success: "Update Erfolgreich"
        delete_success: "Löschen Erfolgreich"
      auth:
        sign_in: Anmeldung
        sign_in_success: "Erfolgreiche Anmeldung"
        sign_in_failure: "Fehlerhafte Anmeldung"
        sign_up: Anmelden
        sign_out: Abmelden
        signed_out: "Sie sind Abgemeldet"
        pwd_update: "Kennwort aktualisieren"
        pwd_update_success: "Ihr Kennwort ist aktualisiert"
        pwd_reset_request: "Kennwort zurücksetzen"
        pwd_reset_req_success: "Ein Mail mit hinweisen um Ihr Kennwort zurücksetzen soll bald ankommen"
      auth_token:
        not_authenticated: "Nicht Authentifiziert."
        invalid: "Der Authentifizierungtoken ist nicht Gültig."
        missing: "Ein Authentifizierungtoken ist gezwungen. Gebe der Token im 'auth_token' param or 'Authorization' header."
      default:
        page_title: Wilkommen
      me:
        email: Mail
        profile: Profil
        next: "Zunächst bitte kontrolliere"
        auth_guides: "Bitte kontrolliere die 'Authentication Guides'"
        modify_page: "Um diese Seite zu Ändern"
        after_signin: "Eine andere Seite nach anmelden"
    ```

    **NOTE:** All lang yml files need all the same keys defined. I18n shard is pretty finicky and its error messages aren't very helpful _(expect a little frustation getting the ymls correct and debugged)._

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
    - update permitted columns
    - update validations

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

    ## Step 7 - Add language to signup page

    TODO: use the same list found in validations (shared constant?)
    ```
    # src/pages/sign_ups/new_page.cr
    class SignUps::NewPage < AuthLayout
      include Lucky::SelectHelpers
      needs operation : SignUpUser

      def content
        h1 "Sign Up"
        render_sign_up_form(@operation)
      end

      private def render_sign_up_form(op)
        form_for SignUps::Create do
          sign_up_fields(op)
          submit "Sign Up", flow_id: "sign-up-button"
        end
        link "Sign in instead", to: SignIns::New
      end

      private def sign_up_fields(op)
        mount Shared::Field.new(op.email), &.email_input(autofocus: "true")
        label_for op.lang, t("user.preferred_language")
        select_input(op.lang) do
          options_for_select(op.lang, LANGUAGES_SELECTOR_LIST)
        end
        mount Shared::Field.new(op.password), &.password_input
        mount Shared::Field.new(op.password_confirmation), &.password_input
      end
    end
    ```

    ## Step 8 - Internationalize Page Displays

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


    **IMPORTANT:** update signup form _(you'll need to style the select to your tastes!)_
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

    Since the following pages inherrit from MainLayout or AuthLayout - no more `require`s and `include`s are needed, just replace the fixed text with translations.
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

    Follow the same logic in the following additional files:
    ```
    # src/pages/password_reset_requests/new_page.cr
    # src/pages/password_resets/new_page.cr
    # src/pages/sign_ins/new_page.cr
    # src/pages/errors/show_page.cr
    ```

    ## Step 9 - Internationalize Flash Messages

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
