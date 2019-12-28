class Guides::Frontend::Internationalization < GuideAction
  guide_route "/frontend/internationalization"

  def self.title
    "Internationalization"
  end

  def markdown : String
    <<-MD
    **Working with multiple languages**

    If these steps are done in oder then Lucky should continue to compile (& be testable) with each change.

    ## Step 1 - Add i18n to `shard.yml`

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

    ## Step 2 - Add localization ymls

    first make a locales folder:
    ```
    mkdir config/locales
    ```

    then add a localization
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
        auth_guides: "Check out the authentication guides"
        modify_page: "Modify this page"
        after_signin: "Change where you go after sign in"
    ```

    ## Step 3 - Configure i18n within Lucky
    ```
    # config/i18n.cr
    I18n.backend = I18n::Backends::YAML.new.tap do |backend|
      backend.load_paths << Dir.current + "/config/locales"
      backend.load
    end
    ```

    ## Step 4 - Add 'lang' to users table
    generate a migration with:
    ```
    lucky db.migration AddLanguageToUser
    ```

    edit the file to look like (of course, the number will vary):
    ```
    # db/migrations/20191228100116_add_language_to_user.cr
    class AddLanguageToUser::V20191228100116 < Avram::Migrator::Migration::V1
      def migrate
        alter table_for(User) do
          add lang : String, default: "en"
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

    ## Step 5 - Add lang column to User model
    ```
    # src/models/user.cr
      table do
        column lang : String
        column email : String
        column encrypted_password : String
       end
    ```

    ## Step 6 - Validate user language choice

    TODO: autodect and autocreate the language list based on the config/locales yml files.
    ```
    # src/operations/sign_up_user.cr
    class SignUpUser < User::SaveOperation
      param_key :user
      # Change password validations in src/operations/mixins/password_validations.cr
      include PasswordValidations

      permit_columns email
      attribute password : String
      attribute password_confirmation : String

      before_save do
        validate_uniqueness_of email
        validate_inclusion_of lang, in: ["en"] # or whatever ymls exist ["en", "de", "fr", "it"]
        Authentic.copy_and_encrypt password, to: encrypted_password
      end
    end
    ```

    ## Step 7 - Add language to signup form

    TODO: use the same list found in validations (shared constant?)
    ```
    # comming soon - when I figure out dropdowns
    ```

    ## Step 8 - Create a Translator class

    _or module or whatever we decide_

    TODO: frontend JS should eventually also be capture and override the user stored preference
    ```
    # src/components/translator.cr
    class Translator
      getter lang : String

      def initialize(user : User? = nil)
        @lang = user.try(&.lang) || "en"
      end

      def t(key : String)
        I18n.t(key, @lang)
      end

      def t(key : String, count : Int32)
        I18n.t(key, @lang, count)
      end
    end
    ```

    ## Step 8 - Internationalize pages

    Basic idea: everywhere there is static text it needs to be replaced with: `I18n.t("default.page_name", @translator.lang)` -- and of course the key needs to be in all the yml files (I18n - ia pretty finicky and its error messages aren't very helpful)
    ```
    abstract class MainLayout
      # ...
      needs current_user : User
      needs translator : Translator
      # ...
      def page_title
        I18n.t("default.page_name", @translator.lang)
        #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      end

      def render
        html_doctype

        html lang: @translator.lang do
          #        ^^^^^^^^^^^^^^^^
          # ...
        end
      end

      private def render_signed_in_user
        # ...
        link I18n.t("auth.sign_out", @translator.lang), to: SignIns::Delete, flow_id: "sign-out-button"
        #    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      end
    end
    ```

    ```
    # src/pages/me/show_page.cr
    class Me::ShowPage < MainLayout
      def content
        h1 I18n.t("me.profile", @translator.lang)
        #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        h3 "\#{I18n.t("me.email", @translator.lang)}:  \#{@current_user.email}"
        #    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        helpful_tips
      end

      private def helpful_tips
        h3 "\#{I18n.t("me.next")}:"
        #    ^^^^^^^^^^^^^^^^^^^^^^
        ul do
          li { link_to_authentication_guides }
          li "\#{I18n.t("me.modify_page", @translator.lang)}: src/pages/me/show_page.cr"
          #    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
          li "\#{I18n.t("me.after_signin", @translator.lang)}: src/actions/home/index.cr"
          #    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        end
      end

      private def link_to_authentication_guides
        link I18n.t("me.auth_guides", @translator.lang), to: "https://luckyframework.org/guides/authentication"
        #    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
        #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      end

      def render
        html_doctype

        html lang: @translator.lang do
          #        ^^^^^^^^^^^^^^^^
          # ...
        end
      end
    end
    ```

    ```
    # src/pages/password_reset_requests/new_page.cr
    class PasswordResetRequests::NewPage < AuthLayout
      needs operation : RequestPasswordReset

      def content
        h1 I18n.t("auth.reset_pwd_request", @translator)
        #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        render_form(@operation)
      end

      private def render_form(op)
        form_for PasswordResetRequests::Create do
          mount Shared::Field.new(op.email), &.email_input
          submit I18n.t("auth.reset_pwd_request", @translator), flow_id: "request-password-reset-button"
          #      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
        #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        render_password_reset_form(@operation)
      end

      private def render_password_reset_form(op)
        form_for PasswordResets::Create.with(@user_id) do
          # ...
          submit I18n.t("auth.update_pwd", @translator), flow_id: "update-password-button"
          #      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        end
      end
    end
    ```

    ```
    # src/pages/sign_ins/new_page.cr
    class SignIns::NewPage < AuthLayout
      needs operation : SignInUser

      def content
        h1 I18n.t("auth.sign_in", @translator)
        #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        render_sign_in_form(@operation)
      end

      private def render_sign_in_form(op)
        form_for SignIns::Create do
          sign_in_fields(op)
          submit I18n.t("auth.sign_in", @translator), flow_id: "sign-in-button"
          #      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        end
        link I18n.t("auth.reset_pwd_request", @translator), to: PasswordResetRequests::New
        #    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        text " | "
        link I18n.t("auth.sign_up", @translator), to: SignUps::New
        #    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      end
      # ...
    end
    ```

    ```
    # src/pages/sign_ups/new_page.cr
    class SignUps::NewPage < AuthLayout
      needs operation : SignUpUser

      def content
        h1 I18n.t("auth.sign_up", @translator)
        #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        render_sign_up_form(@operation)
      end

      private def render_sign_up_form(op)
        form_for SignUps::Create do
          sign_up_fields(op)
          submit I18n.t("auth.sign_up", @translator), flow_id: "sign-up-button"
          #      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        end
        link I18n.t("auth.sign_in", @translator), to: SignIns::New
        #    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      end
      # ...
    end
    ```

    _Thanks to @paulcsmith & @bdtomlin and others for helping and guiding this document._
    MD
  end
end
