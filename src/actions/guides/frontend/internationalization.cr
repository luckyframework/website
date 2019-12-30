class Guides::Frontend::Internationalization < GuideAction
  guide_route "/frontend/internationalization"

  def self.title
    "Internationalization"
  end

  def markdown : String
    <<-MD
    **Working with multiple languages**

    **Summary**
    After configuration translations can be added with:
    ```
    @translator.t("default.page_name")
    # or
    I18n.t("default.page_name", @translator.lang)
    # or
    I18n.t("default.page_name", current_user.lang)
    # or
    I18n.t("default.page_name", Translator::DEFAULT_LANGUAGE)
    # or
    Translator.t("default.page_name", Translator::DEFAULT_LANGUAGE)
    ```

    If these steps are done in oder then Lucky should continue to compile (& be usable/testable) with each change.

    ## Step 1 - Add i18n shard

    ```
    dependencies:
      i18n:
        github: vladfaust/i18n.cr
        version: ~> 0.1.1
    ```

    Add to the end of `shards.cr` file with the new requirements
    ```
    # shards.cr
    # ...
    require "i18n"
    require "i18n/backends/yaml"
    ```

    Install the shard
    ```
    shards install
    ```

    ## Step 2 - Add localization ymls

    Make a locales folder:
    ```
    mkdir config/locales
    ```

    Add at least one localization: i.e. English
    ```
    # config/locales/en.yml
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

    Add additional languages as needed: i.e. German, etc.

    > Be sure that all lang yml files contain the same keys. If there's no translation for that key, just leave the value blank.

    ## Step 3 - Configure i18n within Lucky
    ```
    # config/i18n.cr
    I18n.backend = I18n::Backends::YAML.new.tap do |backend|
      backend.load_paths << Dir.current + "/config/locales"
      backend.load
    end
    ```

    ## Step 4 - Add 'lang' to users table

    Generate a migration using:
    ```
    lucky db.migration AddLanguageToUser
    ```

    Edit the file to look like (of course, the number will vary):
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

    And migrate
    ```
    lucky db.migrate
    ```

    ## Step 5 - Add lang column to User model
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

    ## Step 6 - Create a Translator class

    ```
    # src/components/translator.cr
    class Translator
      getter lang : String

      DEFAULT_LANGUAGE = "en"
      AVAILABLE_LANGUAGES = ["en", "de"]
      LANGUAGES_SELECTOR_LIST = [{"English", "en"}, {"Deutsch", "de"}]

      def initialize(user : User? = nil)
        @lang = user.try(&.lang) || DEFAULT_LANGUAGE
      end

      def t(key : String)
        I18n.t(key, @lang)
      end

      def t(key : String, count : Int32)
        I18n.t(key, @lang, count)
      end
    end
    ```

    ## Step 7 - Update Operations

    All Operation Files with translations need:
    - add `require "../components/translator"` at the top of the file when needed for operations
    - add translations

    SignUpUser also need the folowing:
    - Add `lang` to `permit_columns`
    - Add a validation for `lang` to prevent errors

    ```
    # src/operations/sign_up_user.cr
    class SignUpUser < User::SaveOperation
      # ...
      permit_columns email, lang
      # ...
      before_save do
        # ...
        validate_inclusion_of lang, in: LANGUAGES_AVAILABLE
        # ...
      end
    end
    ```

    SignInUser has translations without a user
    ```
    # src/operations/sign_in_user.cr
    require "../components/translator"

    class SignInUser < Avram::Operation
      # ...
      private def validate_credentials(user)
        if user
          unless Authentic.correct_password?(user, password.value.to_s)
            password.add_error I18n.t("error.auth_incorrect", Translator::DEFAULT_LANGUAGE)
          end
        else
          # ...
          email.add_error I18n.t("error.not_in_system", Translator::DEFAULT_LANGUAGE)
        end
      end
    end
    ```

    Similarly RequestPasswordReset would look like:
    ```
    # src/operations/request_password_reset.cr
    require "../components/translator"

    class RequestPasswordReset < Avram::Operation
      # ...
      def validate(user : User?)
        # ...
        if user.nil?
          email.add_error I18n.t("error.not_in_system", Translator::DEFAULT_LANGUAGE)
        end
      end
    end
    ```

    ## Step 8 - Internationalize Layouts

    Every abstract class needs the Translator (then its available in the Pages)
    - this example shows two different ways to use the translator with a User available
    ```
    abstract class MainLayout
      # ...
      needs translator : Translator
      # ...
      def page_title
        I18n.t("default.page_title", @current_user.lang)
      end

      def render
        # ..
        html lang: @translator.lang do
          # ...
        end
      end

      private def render_signed_in_user
        # ...
        link @translator.t("auth.sign_out"), to: SignIns::Delete, flow_id: "sign-out-button"
      end
    end
    ```

    ```
    # src/pages/auth_layout.cr
    abstract class AuthLayout
      # ...
      needs translator : Translator

      def page_title
        I18n.t("default.page_name", @translator.lang)
      end

      def render
        # ...
        html lang: @translator.lang do
          # ...
        end
      end
    end
    ```

    ## Step 9 - Add language preference to signup form

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
    ## Step 10 - Internationalize Pages

    - Everywhere there is static text translations can be added.

    ```
    # src/pages/me/show_page.cr
    class Me::ShowPage < MainLayout
      def content
        h1 I18n.t("me.profile", @translator.lang)
        h3 "\#{I18n.t("me.email", @translator.lang)}:  \#{@current_user.email}"
        # ...
      end

      private def helpful_tips
        h3 "\#{I18n.t("me.next", @translator.lang)}:"
        ul do
          # ...
          li "\#{I18n.t("me.modify_page", @translator.lang)}: src/pages/me/show_page.cr"
          li "\#{I18n.t("me.after_signin", @translator.lang)}: src/actions/home/index.cr"
        end
      end

      private def link_to_authentication_guides
        link I18n.t("me.auth_guides", @translator.lang), to: "https://luckyframework.org/guides/authentication"
      end
    end
    ```

    Similarly, add translations to the files:
    ```
    # src/pages/password_reset_requests/new_page.cr
    # src/pages/password_resets/new_page.cr
    # src/pages/sign_ins/new_page.cr
    ```

    The show errors page has no template so it needs the following modifications
    ```
    # src/pages/errors/show_page.cr
    class Errors::ShowPage
      # ...
      def render
        # ...
        html lang: Translator::DEFAULT_LANGUAGE do
          head do
            # ...
            title I18n.t("error.title", Translator::DEFAULT_LANGUAGE)
            # ...
          end

          body do
            div class: "container" do
              # ...
              ul class: "helpful-links" do
                li do
                  link I18n.t("error.try_home", Translator::DEFAULT_LANGUAGE), to: "/", class: "helpful-link"
                end
              end
            end
          end
        end
      end
      # ...
    end
    ```

    ## Step 11 - Internationalize Actions
    ```
    # src/actions/browser_action.cr
    abstract class BrowserAction < Lucky::Action
    # ...
    expose current_user
    def translator
      Translator.new(current_user)
    end
    expose translator
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
            flash.success = translator.t("auth.success")
            # ...
          else
            flash.failure = I18n.t("auth.failure", Translator::DEFAULT_LANGUAGE)
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

    ## Step 12 - Internationalize API Responses
    Given the deep namespace for the API - the require statement is a bit clumsy looking but works.
    ```
    # src/actions/mixins/api/auth/require_auth_token.cr
    module Api::Auth::RequireAuthToken
      include Translator
      # ...
      private def auth_error_json
        ErrorSerializer.new(
          message: I18n.t("auth_token.not_authenticated", Translator::DEFAULT_LANGUAGE),
          # ...
        )
      end

      private def auth_error_details : String
        if auth_token
          I18n.t("auth_token.invalid", Translator::DEFAULT_LANGUAGE)
        else
          I18n.t("auth_token.invalid", Translator::DEFAULT_LANGUAGE)
        end
      end
      # ...
    end
    ```
    MD
  end
end
