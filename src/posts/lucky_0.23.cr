class Lucky023Release < BasePost
  title "Lucky v0.23 is out, and it's huge!"
  slug "lucky-0_23-release"

  def published_at : Time
    Time.utc(year: 2020, month: 6, day: 30)
  end

  def summary : String
    <<-TEXT
    Lucky v0.23 is out now. Lots of new features, bug fixes,
    and even some performance boosts!
    TEXT
  end

  def content : String
    <<-MD
    [Lucky v0.23](https://github.com/luckyframework/lucky/blob/master/CHANGELOG.md#changes-in-023)
    is out now and works with the newest version of Crystal (v0.35.0)

    Be sure to upgrade your version of Crystal, and take a look at our
    [UPGRADE NOTES](https://github.com/luckyframework/lucky/blob/master/UPGRADE_NOTES.md#upgrading-from-022-to-023)
    for help with migrating your app.

    ### LuckyDiff

    Thanks to a community member [@stephendolan](https://github.com/stephendolan/lucky_diff) for
    creating this awesome tool, we have started linking to it in our UPGRADE_NOTES to help you
    see what the differences are between versions!

    ## Quick Updates

    * `mount` -> `m`
    * params strip whitespace, `get_raw`
    * `memoize` is better
    * security fix with html helper escapes

    ## Routing Updates

    * route_prefix
    * optional path params
    * performance 

    ## CLI Task Args

    ## Lucky Flow



    ## Parting words

    This release has seen a huge surge in community contributions. It's tough maintaining
    open source projects, so we just want to say how much we appreciate all of the hard work
    the community has put in to Lucky making this framework so amazing! 

    We're really excited about getting closer to a 1.0.0 release, and we can't do it without
    your support. Please give it a spin and help us find bugs so our next release is even more solid.
    If you find any issues, don't hesitate to [report the issue](https://github.com/luckyframework/lucky/issues).
    If you're unsure, just hop on [gitter chat](https://gitter.im/luckyframework/Lobby) so we can help you out.

    Thanks so much for the support!

    ### Follow and spread the word

    If you haven't already, give us a [star on github](https://github.com/luckyframework/lucky),
    and be sure to follow us on [Twitter](https://twitter.com/luckyframework/).

    For questions, or just to chat, come say hi on [gitter](https://gitter.im/luckyframework/Lobby).
    MD
  end
end
