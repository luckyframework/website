class Lucky016Release < BasePost
  title "Lucky 0.17 has been released!"
  slug "lucky-0_17-release"

  def published_at
    Time.utc(year: 2019, month: 8, day: 16)
  end

  def summary
    <<-TEXT
    Lucky v0.17 is a huge release with many enhancements to Avram, Lucky's
    database library for Postgres.
    TEXT
  end

  def content
    <<-MD
    Lucky v0.17.0 is now out and has support for the newest Crystal (v0.30.0)!

    ### What's new?

    You can see a [full list of
    changes](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-v017),
    but here are some highlights.

    [Avram](https://github.com/luckyframework/avram) has seen the most changes
    and improvements.

    * Can now use any column as the primary key. Can also use Int64, UUID or any custom type you implement.
    * Added ability to customize default columns (primary key, timestamps, etc.).
    * Lots of improvements to how we save and query records.

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [gitter](https://gitter.im/luckyframework/Lobby).
    MD
  end
end
