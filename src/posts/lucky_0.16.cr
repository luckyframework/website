class Lucky016Release < BasePost
  title "Lucky 0.16 has been released!"
  slug "lucky-0_16-release"

  def published_at : Time
    Time.utc(year: 2019, month: 8, day: 5)
  end

  def summary : String
    <<-TEXT
    Lucky v0.16 is a small release with support for Crystal 0.30. Keep an eye
    out for the next big Lucky release which will be out soon.
    TEXT
  end

  def content : String
    <<-MD
    Lucky v0.16.0 is now out and has support for the newest Crystal (v0.30.0)!

    We decided to keep this release small so you have a chance to upgrade Crystal,
    and not worry about so many changes to Lucky (yet 😉). This release is the same
    as v0.15.1 which was released on June 12th, 2019.

    Please be sure to report any [issues](https://github.com/luckyframework/lucky/issues) you
    may run in to. Using this version will help us to launch the next version quicker which will
    be huge!

    ### 0.17 sneak peek

    Just a few things on the way:

    * Postgres JSON and Array support
    * Polymorphic associations
    * More primary key support
    * Int16 / Int64 Postgres columns
    * Much more...

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Bluesky](https://bsky.app/profile/luckyframework.org/).

    For questions, or just to chat, come say hi on [gitter](https://gitter.im/luckyframework/Lobby).
    MD
  end
end
