class Guides::Frontend::Internationalization < GuideAction
  guide_route "/frontend/internationalization"

  def self.title
    "Internationalization"
  end

  def markdown : String
    <<-MD
    **Working with multiple languages**

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
    en:
      auth:
        sign_in: "Sign-In"
        sign_up: "Sign-up"
        update_pwd: "Update Password"
        reset_pwd_request: "Reset Password"
      default:
        page_name: Welcome
      me:
        email: E-Mail
        profile: Profile
        next: "Next, you may want to"
        auth_guides: "Check out the Authentication Guides"
        modify_page: "Modify this page"
        after_signin: "Change where you go after sign in"
    ```

    Add additional languages as needed: i.e. German, etc.
    ```
    # config/locales/de.yml
    de:
      auth:
        sign_in: Anmeldung
        sign_up: Anmelden
        sign_out: Abmelden
        update_pwd: "Kennwort aktualisieren"
        reset_pwd_request: "Kennwort zurücksetzen"
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

    Add `lang` to `permit_columns`
    Add a validation for `lang` to prevent errors

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

    ## Step 8 - Add language to signup form

    ```
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

    ## Step 8 - Internationalize pages

    Basic ideas:
    - every abstract class needs the Translator (i.e. MainLayout and AuthLayout)
    - everywhere there is static text (in a concrete or abstract layout) translations can be added with: `I18n.t("default.page_name", @translator.lang)`
    ```
    abstract class MainLayout
      # ...
      needs translator : Translator
      # ...
      def page_title
        I18n.t("default.page_name", @translator.lang)
      end

      def render
        # ...
        html lang: @translator.lang do
          # ...
        end
      end

      private def render_signed_in_user
        # ...
        link I18n.t("auth.sign_out", @translator.lang), to: SignIns::Delete, flow_id: "sign-out-button"
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

    ```
    # src/pages/password_reset_requests/new_page.cr
    class PasswordResetRequests::NewPage < AuthLayout
      # ...
      def content
        h1 I18n.t("auth.reset_pwd_request", @translator)
        # ...
      end

      private def render_form(op)
        form_for PasswordResetRequests::Create do
          # ...
          submit I18n.t("auth.reset_pwd_request", @translator), flow_id: "request-password-reset-button"
        end
      end
    end
    ```

    ```
    # src/pages/password_resets/new_page.cr
    class PasswordResets::NewPage < AuthLayout
      # ...
      def content
        h1 I18n.t("auth.update_pwd", @translator)
        render_password_reset_form(@operation)
      end

      private def render_password_reset_form(op)
        form_for PasswordResets::Create.with(@user_id) do
          # ...
          submit I18n.t("auth.update_pwd", @translator), flow_id: "update-password-button"
        end
      end
    end
    ```

    ```
    # src/pages/sign_ins/new_page.cr
    class SignIns::NewPage < AuthLayout
      # ...
      def content
        h1 I18n.t("auth.sign_in", @translator)
        # ...
      end

      private def render_sign_in_form(op)
        form_for SignIns::Create do
          # ...
          submit I18n.t("auth.sign_in", @translator), flow_id: "sign-in-button"
        end
        link I18n.t("auth.reset_pwd_request", @translator), to: PasswordResetRequests::New
        text " | "
        link I18n.t("auth.sign_up", @translator), to: SignUps::New
      end
      # ...
    end
    ```

    ```
    # src/pages/sign_ups/new_page.cr
    class SignUps::NewPage < AuthLayout
      # ...
      def content
        h1 I18n.t("auth.sign_up", @translator)
        # ...
      end

      private def render_sign_up_form(op)
        form_for SignUps::Create do
          # ...
          submit I18n.t("auth.sign_up", @translator), flow_id: "sign-up-button"
        end
        link I18n.t("auth.sign_in", @translator), to: SignIns::New
      end
      # ...
    end
    ```
    MD
  end
end
