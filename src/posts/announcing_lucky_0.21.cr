class Lucky021Release < BasePost
  title "Lucky v0.21 introduces a beautiful new log experience."
  slug "lucky-0_21-release"

  def published_at : Time
    Time.utc(year: 2020, month: 4, day: 22)
  end

  def summary : String
    <<-TEXT
    Lucky v0.21 is out now. This release is a straightforward upgrade that
    adds new Log methods and improvements to the logs in dev.
    TEXT
  end

  def content : String
    <<-MD
    [Lucky v0.21](https://github.com/luckyframework/lucky/blob/main/CHANGELOG.md#changes-in-021)
    is out now and works with the newest version of Crystal (v0.34.0)

    Be sure to upgrade your version of Crystal, and take a look at our
    [UPGRADE NOTES](https://github.com/luckyframework/lucky/blob/main/UPGRADE_NOTES.md#upgrading-from-020-to-021)
    for help with migrating your app.

    ## Clearer logs

    Logged errors are now much easier to find and understand.

    * Make it super clear where the error begins
    * Highlight where backtrace begins
    * Dims non-app code lines so you can focus on your app's code

    <div class="shadow rounded overflow-hidden my-8">
      <img alt="Picture of error log" src="#{Lucky::AssetHelpers.asset("images/new-error-log.jpg")}">
    </div>

    Lucky also includes the HTTP status in English so you don't need to google
    status codes as much:

    <div class="shadow rounded overflow-hidden inline-block">
      <img alt="Picture of error log" src="#{Lucky::AssetHelpers.asset("images/http-status-log.png")}">
    </div>

    ## Switch to Crystal v0.34 Log class

    Lucky v0.21 now uses the
    [Log](https://crystal-lang.org/api/0.34.0/Log.html) class that was added
    in Crystal v0.34.0. `Log` gives us lot of goodies like like adding
    context to log entries, simpler configuration, and better performance.

    ## New version of Dexter

    This release also uses the newest version of [Dexter](https://github.com/luckyframework/dexter)
    which extends the built-in Crystal Log with all kinds of great abilities.

    * Helpers for testing log messages
    * Built in formatters that print production ready log messages
    * Type-safe configuration
    * Methods for logging key/value data

    ## Parting words

    We're very excited about this release, and hope you are too. Please give it a spin and help
    us find bugs so our next release is even more solid. If you find any issues, don't hesitate
    to [report the issue](https://github.com/luckyframework/lucky/issues). If you're unsure, just
    hop on [gitter chat](https://gitter.im/luckyframework/Lobby) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Bluesky](https://bsky.app/profile/luckyframework.org/).

    For questions, or just to chat, come say hi on [gitter](https://gitter.im/luckyframework/Lobby).
    MD
  end
end
