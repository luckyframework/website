class Guides::Frontend::Internationalization < GuideAction
  guide_route "/frontend/internationalization"

  def self.title
    "Internationalization - Handle Multiple Languages"
  end

  def markdown : String
    <<-MD
    This describes how to handle USERS with multiple language preferences.  At somepoint we can document how to add dynamic switching from the frontend too.

    ## **Step 1** - add i18n shard to `shard.yml`

    ```
    dependencies:
      i18n:
        github: vladfaust/i18n.cr
        version: ~> 0.1.1
    ```
    and of course install the shard
    ```
    shards install
    ```

    ## **Step 2** - add a starter localization and anothers needed:

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
        email: Mail
        profile: Profil
        next: "Next, you may want to"
        auth_guides: "Check out the authentication guides"
        modify_page: "Modify this page"
        after_signin: "Change where you go after sign in"
    ```

    ## **Step 3** - configure i18n to work with Lucky
    ```
    # config/i18n.cr
    require "i18n"
    require "i18n/backends/yaml"
      I18n.backend = I18n::Backends::YAML.new.tap do |backend|
      backend.load_paths << Dir.current + "/config/locales"
      backend.load
    end
    ```

    ## **Step 4** - create a user migration
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

    ## **Step 5** - update the user model (add the new attribute)
    ```
    # src/models/user.cr
      table do
        column lang : String
        column email : String
        column encrypted_password : String
       end
    ```

    ## **Step 6** - Update sign_up_user.cr (to validate the available languages) - ideally at somepoint in the future - lucky will autodect and autocreate the language list based on the config/locales yml files.
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

    ## **Step 7** - create a translator - could the JS capture be integrated into this class?
    ```
    # src/components/translator.cr
    class Translator
      getter lang : String

      def initialize(user : User? = nil)
        @lang = user.try(&.lang) || "en"
      end

      def t(key : String)
        I18n.t(key, @lang) # this seems better but not available
      end

      def t(key : String, count : Int32)
        I18n.t(key, @lang, count) # this seems better but not available
      end
    end
    ```

    ## **Step 8** - then update authentication the pages (and others)
    ```
    abstract class MainLayout
      include Lucky::HTMLPage

      # 'needs current_user : User' makes it so that the current_user
      # is always required for pages using MainLayout
      needs current_user : User
      needs translator : Translator

      abstract def content
      abstract def page_title

      # The default page title. It is passed to `Shared::LayoutHead`.
      #
      # Add a `page_title` method to pages to override it. You can also remove
      # This method so every page is required to have its own page title.
      def page_title
        I18n.t("default.page_name", @translator.lang)
      end

      def render
        html_doctype

        html lang: @translator.lang do
          # mount Shared::LayoutHead.new(page_title: page_title, context: @context)

          body do
            mount Shared::FlashMessages.new(@context.flash)
            render_signed_in_user
            content
          end
        end
      end

      private def render_signed_in_user
        text @current_user.email
        text " - "
        link I18n.t("auth.sign_out", @translator.lang), to: SignIns::Delete, flow_id: "sign-out-button"
      end
    end
    ```

    ```
    # src/pages/me/show_page.cr
    class Me::ShowPage < MainLayout
      def content
        h1 I18n.t("me.profile", @translator.lang)
        h3 "#{I18n.t("me.email", @translator.lang)}:  #{@current_user.email}"

        helpful_tips
      end

      private def helpful_tips
        h3 "#{I18n.t("me.next")}:"
        ul do
          li { link_to_authentication_guides }
          li "#{I18n.t("me.modify_page", @translator.lang)}: src/pages/me/show_page.cr"
          li "#{I18n.t("me.after_signin", @translator.lang)}: src/actions/home/index.cr"
        end
      end

      private def link_to_authentication_guides
        link I18n.t("me.auth_guides", @translator.lang),
          to: "https://luckyframework.org/guides/authentication"
      end
    end
    ```

    ```
    # src/pages/auth_layout.cr
    abstract class AuthLayout
      include Lucky::HTMLPage

      abstract def content
      abstract def page_title

      needs translator : Translator

      # The default page title. It is passed to `Shared::LayoutHead`.
      #
      # Add a `page_title` method to pages to override it. You can also remove
      # This method so every page is required to have its own page title.
      def page_title
        I18n.t("default.page_name", @translator.lang)
      end

      def render
        html_doctype

        html lang: @translator.lang do
          mount Shared::LayoutHead.new(page_title: page_title, context: @context)

          body do
            mount Shared::FlashMessages.new(@context.flash)
            content
          end
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
        render_form(@operation)
      end

      private def render_form(op)
        form_for PasswordResetRequests::Create do
          mount Shared::Field.new(op.email), &.email_input
          submit I18n.t("auth.reset_pwd_request", @translator), flow_id: "request-password-reset-button"
        end
      end
    end
    ```

    ```
    # src/pages/password_resets/new_page.cr
    class PasswordResets::NewPage < AuthLayout
      needs operation : ResetPassword
      needs user_id : Int64

      def content
        h1 I18n.t("auth.update_pwd", @translator)
        render_password_reset_form(@operation)
      end

      private def render_password_reset_form(op)
        form_for PasswordResets::Create.with(@user_id) do
          mount Shared::Field.new(op.password), &.password_input(autofocus: "true")
          mount Shared::Field.new(op.password_confirmation), &.password_input

          submit I18n.t("auth.update_pwd", @translator), flow_id: "update-password-button"
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
        render_sign_in_form(@operation)
      end

      private def render_sign_in_form(op)
        form_for SignIns::Create do
          sign_in_fields(op)
          submit I18n.t("auth.sign_in", @translator), flow_id: "sign-in-button"
        end
        link I18n.t("auth.reset_pwd_request", @translator), to: PasswordResetRequests::New
        text " | "
        link I18n.t("auth.sign_up", @translator), to: SignUps::New
      end

      private def sign_in_fields(op)
        mount Shared::Field.new(op.email), &.email_input(autofocus: "true")
        mount Shared::Field.new(op.password), &.password_input
      end
    end
    ```

    ```
    # src/pages/sign_ups/new_page.cr
    class SignUps::NewPage < AuthLayout
      needs operation : SignUpUser

      def content
        h1 I18n.t("auth.sign_up", @translator)
        render_sign_up_form(@operation)
      end

      private def render_sign_up_form(op)
        form_for SignUps::Create do
          sign_up_fields(op)
          submit I18n.t("auth.sign_up", @translator), flow_id: "sign-up-button"
        end
        link I18n.t("auth.sign_in", @translator), to: SignIns::New
      end

      private def sign_up_fields(op)
        mount Shared::Field.new(op.email), &.email_input(autofocus: "true")
        mount Shared::Field.new(op.password), &.password_input
        mount Shared::Field.new(op.password_confirmation), &.password_input
      end
    end
    ```

    _Thanks to @paulcsmith & @bdtomlin and others for helping and guiding this document._
    MD
  end
end
