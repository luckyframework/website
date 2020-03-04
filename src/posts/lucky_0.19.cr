class Lucky019Release < BasePost
  title "Lucky 0.19 is out now."
  slug "lucky-0_19-release"

  def published_at : Time
    Time.utc(year: 2020, month: 3, day: 4)
  end

  def summary : String
    <<-TEXT
    Lucky v0.19. Support for Crystal 0.33.0, attribute change tracking, and
    performance improvements.
    TEXT
  end

  def content : String
    <<-MD
    Lucky v0.19 is now out and works with the newest version of Crystal (v0.33.0)

    Be sure to upgrade your version of Crystal, and take a look at our
    [UPGRADE NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-018-to-019)
    for help with migrating your app.

    ## What's new?

    This release includes bug fixes, enhancements, doc improvements, and new features.
    You can see a full list on our [CHANGELOG](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-019).

    Here are some of the most important enhancements.

    ### Change tracking

    Somtimes you want to perform an action only if certain attributes change,
    or you may want to audit changes to database attributes. This is now
    simple to do with the new change tracking methods on attributes:

    ```crystal
    class SaveUser < User::SaveOperation
      permit_columns email, admin

      before_save do
        if admin.changed?(to: true)
          # Send an email, add permissions, etc.
        end

        if name.changed?
          Lucky.logger.info(name_changed_from: name.original_value, to: name.value)
        end
      end
    end
    ```

    View more details in the
    [change tracking guide]#{Guides::Database::ValidatingSaving.path(anchor: Guides::Database::ValidatingSaving::ANCHOR_CHANGE_TRACKING)}).

    ### Built-in Gzipping (compression) of static assets

    By default Lucky's webpack setup will now compress assets with Gzip when
    in production. Lucky's new `Lucky::StaticCompressionHandler.new` will
    look for gzipped assets and use those if the client accepts Gzipped
    content. The handler can also be customized to look for assets compressed
    with other algorithms like Brotli.

    ### Built-in Gzipping of text responses

    Text responses like HTML, JSON, and XML are now Gzipped by default when
    in production. This can be disabled if you have something in front of
    Lucky that handles gzipping, but making this the default out of the box
    experience means people should have an even easier time making high
    performance applications with Lucky.

    ## Parting words

    We're very excited about this release, and hope you are too. Please give it a spin and help
    us find bugs so our next release is even more solid. If you find any issues, don't hesitate
    to [report the issue](https://github.com/luckyframework/lucky/issues). If you're unsure, just
    hop on [gitter chat](https://gitter.im/luckyframework/Lobby) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [gitter](https://gitter.im/luckyframework/Lobby).
    MD
  end
end
