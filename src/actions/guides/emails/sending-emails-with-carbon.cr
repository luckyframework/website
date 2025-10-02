class Guides::Emails::SendingEmailsWithCarbon < GuideAction
  guide_route "/emails/sending-emails-with-carbon"

  def self.title
    "Sending Emails with Carbon"
  end

  def markdown : String
    <<-MD
    ## Configuring Email

    Lucky leverages the [Carbon](https://github.com/luckyframework/carbon) library for writing, sending, and testing emails.
    Carbon can be configured using the default file generated with a new Lucky application in `config/email.cr`. In that file
    you can add SendGrid keys and change adapters.

    ## Adapters

    Carbon supports a growing number of adapters thanks to contributions from the community. [View supported adapters](https://github.com/luckyframework/carbon#adapters)

    > If you've built an adapter not listed, be sure to let us know!

    ### Dev Adapter

    The `DevAdapter` ships with Carbon by default, and is useful for handling emails in a development or test environment.
    It can also be leveraged in production to effectively disable emails.

    There are two ways to leverage the `DevAdapter`. The first is by telling the adapter to simply capture all Carbon output
    without printing or displaying the email content, which is the default:

    ```crystal
    # config/email.cr
    BaseEmail.configure do |settings|
      settings.adapter = Carbon::DevAdapter.new
    end
    ```

    If you want to see your email content printed to your development or test server logs, you can use the optional `print_emails` flag:

    ```crystal
    # config/email.cr
    BaseEmail.configure do |settings|
      settings.adapter = Carbon::DevAdapter.new(print_emails: true)
    end
    ```

    ### SendGrid Adapter

    The [SendGridAdapter](https://github.com/luckyframework/carbon_sendgrid_adapter) ships with Lucky by default,
    and once configured will send all emails through the [SendGrid](https://sendgrid.com) email service.

    Initializing the `SendGridAdapter` is as simple as initializing the adapter with your SendGrid API key in `config/email.cr`:

    ```crystal
    # config/email.cr
    BaseEmail.configure do |settings|
      settings.adapter = Carbon::SendGridAdapter.new(api_key: ENV["SEND_GRID_KEY"])
    end
    ```

    > Be sure the `carbon_sendgrid_adapter` shard is listed in your `shard.yml` dependencies.

    ## Creating Emails

    Emails are setup and configured through Crystal classes that live in your `src/emails/` directory. In that directory, you should already have a
    `base_email.cr` file. This is the abstract class all of your email objects will inherit from. Use the `BaseEmail` for any defaults that
    should be applied to all of your emails (e.g. `default_from` address, etc...)

    The views (HTML) related to the emails will reside in the `src/emails/templates/{ NAME_OF_EMAIL }/` directory. For example, if your email file
    is named `welcome_email.cr`, the templates for this will live in `src/emails/templates/welcome_email/`.

    > You can also check out the `PasswordResetEmail` in the `src/emails/` directory of a newly generated auth project for a live example.

    ### Email templates

    There are two basic templates for emails; HTML, and TEXT. The HTML template will be where you write the raw HTML for your email. The TEXT format
    is used as a plain text (no HTML) email for devices and/or email apps that don't support HTML.

    Place the templates inside of each specific email directory they belong to. Then name them `html.ecr`, and `text.ecr`. For example, if your email
    file is named `welcome_email.cr`, your templates will be in `src/emails/templates/welcome_email/html.ecr` and `src/emails/templates/welcome_email/text.ecr`.

    The email templates will use [ECR](https://crystal-lang.org/api/1.0.0/ECR.html) for interpolating Crystal code. All instance variables/methods defined in
    your email class will be available within your template.

    ```html
    <!-- src/emails/templates/welcome_email/html.ecr -->
    <h1>Welcome, <%= @user.name %>!</h1>
    <p>...</p>
    <p>Secret token <%= @token %>.</p>
    <p>Thanks, <%= email_signature %></p>
    ```

    ### Email class

    In the `BaseEmail`, you can set defaults that will apply to all of your emails. This includes setting special email headers, `from` address,
    or maybe helper methods you need to use in your email templates.

    ```crystal
    # src/emails/base_email.cr
    abstract class BaseEmail < Carbon::Email
      macro inherited
        from default_from
        header "Return-Path", "hello@myapp.io"
        header "Message-ID", default_message_id
      end

      def default_from
        Carbon::Address.new("hello@myapp.io")
      end

      def default_message_id
        digest = OpenSSL::Digest.new("SHA256")
        digest.update(Time.utc.to_unix.to_s)
        message_id = digest.final.hexstring

        "<\#{message_id}@myapp.io>"
      end

      def email_signature : String
        "The MyApp Crew"
      end
    end
    ```

    ```crystal
    # src/emails/welcome_email.cr
    class WelcomeEmail < BaseEmail

      # Define your own initializer with the
      # references it needs
      def initializer(@user : User)
        encryptor = Lucky::MessageEncryptor.new(secret: Lucky::Server.settings.secret_key_base)

        # Instance variables defined are available in your templates
        @token = encryptor.encrypt_and_sign("\#{@user.id}:\#{24.hours.from_now.to_unix_ms}")
      end

      to @user
      subject "Welcome to MyApp.io!"
      templates html, text
    end
    ```

    ## Sending Emails

    There's two strategies to sending emails; deliver now, or deliver later.

    ### Deliver email now

    Once your email class is defined, you can call the `deliver` method to send now.

    ```crystal
    WelcomeEmail.new(current_user).deliver
    ```

    ### Deliver email later

    If you need to delay sending the email, call the `deliver_later` method to send later.

    ```crystal
    WelcomeEmail.new(current_user).deliver_later
    ```

    [read more](https://github.com/luckyframework/carbon#delay-email-delivery) on the `deliver_later` strategy.

    ### Marking emails as undeliverable

    In cases where you may need to avoid sending emails programmatically, Carbon emails have
    a `deliverable` property that is set to `true` by default, but can be set to `false` as needed.
    When `false`, the `deliver` and `deliver_later` won't send.

    ```crystal
    email = MarketingEmail.new(current_user)

    if current_user.has_unsubscribed?
      email.deliverable = false
    end

    email.deliver
    ```

    ## Before / After send callbacks

    Carbon emails have two callbacks available; `before_send` and `after_send`. These callbacks
    can be used for things like marking an email as undeliverable, or tracking when emails are sent.

    ```crystal
    class MarketingEmail < BaseEmail
      before_send do
        if @recipient.has_unsubscribed?
          self.deliverable = false
        end
      end

      after_send do |response|
        MarkEmailSent.create!(recipient: @recipient, response: response)
      end

      def initialize(@recipient : Carbon::Emailable)
      end

      # ...
    end
    ```

    The `after_send` will yield the return value of sending the email. This value will be different
    depending on the Carbon Adapter you're using. For SendGrid, this will be the `HTTP::Client::Response`
    of the API call.

    ## Email Attachments

    Each file attachment will use a NamedTuple with the keys dependant on if the file is located physically on disk,
    or in-memory using an IO. Below is an example of multiple attachments using each style.

    ```crystal
    # src/emails/purchase_email.cr
    class PurchaseEmail < BaseEmail

      # Define your own initializer with the
      # references it needs
      def initializer(@user : User, @purchase : Purchase)
      end

      to @user
      subject "Thank you for your purchase"
      templates html, text
      attachment receipt
      attachment logo

      # Attach file using in-memory IO
      def receipt : Carbon::AttachIO
        {
          io: IO::Memory.new(@purchase.to_pdf_format),
          file_name: "purchase_receipt.pdf",
          mime_type: "application/pdf"
        }
      end

      # Attach file using path to file
      def logo : Carbon::AttachFile
        {
          file_path: "./path/to/logo.png",
          file_name: "logo.png",
          mime_type: "image/png"
        }
      end
    end
    ```

    ## Testing Emails

    Carbon comes with a few methods you can use in your specs to ensure emails are being sent. [read more](https://github.com/luckyframework/carbon#testing)

    To configure testing your emails, you'll need to add `include Carbon::Expectations` in to `spec/spec_helper.cr`.
    Then to make sure that emails are cleared between specs, you need to add `spec/setup/reset_emails.cr` with

    ```crystal
    Spec.before_each do
      Carbon::DevAdapter.reset
    end
    ```

    ### be_delivered expectation

    The `be_delivered` expectation is used to assert a specific email was delivered.

    > This only checks that the `deliver` method was called. It does not account for API hanlding in other adapters.

    ```crystal
    it "delivers the email" do
      user = UserFactory.create &.email("emily@gmail.com")
      WelcomeEmail.new(user).deliver_now

      # Test that this email was sent
      WelcomeEmail.new(user).should be_delivered
    end
    ```

    ### have_delivered_emails expectation

    The `have_delivered_emails` is a bit more generic, and asserts that Carbon sent *any* email.

    ```crystal
    it "delivers the email" do
      user = UserFactory.create &.email("emily@gmail.com")
      WelcomeEmail.new(user).deliver_now

      # Test that any email was sent
      Carbon.should have_delivered_emails
    end
    ```

    MD
  end
end
