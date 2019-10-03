class Guides::Emails::SendingEmailsWithCarbon < GuideAction
  guide_route "/emails/sending-emails-with-carbon"

  def self.title
    "Sending Emails with Carbon"
  end

  def markdown : String
    <<-MD
    ## Configuring Carbon

    Lucky generates default configuration in `config/email.cr`. In that file you
    can add SendGrid keys and change adapters.

    ## Sending and testing emails

    See the README at https://github.com/luckyframework/carbon

    You can also check out the `PasswordResetEmail` in the `src/emails` directory
    of a newly generated project.
    MD
  end
end
