class Guides::Emails::SendingEmailsWithCarbon < GuideAction
  guide_route "/emails/sending-emails-with-carbon"

  def self.title
    "Sending Emails with Carbon"
  end

  def markdown : String
    <<-MD
    ## Configuring Email

    Lucky leverages the [Carbon](https://github.com/luckyframework/carbon) library for writing, sending, and testing emails. Carbon can be configured using the default file generated with a new Lucky application in `config/email.cr`. In that file you can add SendGrid keys and change adapters.

    ## Adapters
    
    Carbon supports a growing number of adapters thanks to contributions from the community.

    ### Dev Adapter
    
    The `DevAdapter` ships with Carbon by default, and is useful for handling emails in a development or test environment. It can also be leveraged in production to effectively disable emails.

    There are two ways to leverage the `DevAdapter`. The first is by telling the adapter to simply capture all Carbon output without printing or displaying the email content, which is the default:

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

    The `SendGridAdapter` ships with Carbon by default, and once configured will send all emails through the [SendGrid](https://sendgrid.com) email service.
    
    Initializing the `SendGridAdapter` is as simple as initializing the adapter with your SendGrid API key in `config/email.cr`:

    ```crystal
    # config/email.cr
    BaseEmail.configure do |settings|
      settings.adapter = Carbon::SendGridAdapter.new(api_key: ENV["SEND_GRID_KEY"])
    end
    ```

    ## Sending and testing emails

    See the README at https://github.com/luckyframework/carbon

    You can also check out the `PasswordResetEmail` in the `src/emails` directory
    of a newly generated project.
    MD
  end
end
