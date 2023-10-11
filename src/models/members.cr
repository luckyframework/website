module Members
  extend self

  record Member,
    fullname : String,
    title : String,
    github : String,
    twitter_link : String? = nil,
    mastodon_link : String? = nil

  def creator
    Member.new(
      fullname: "Paul Smith",
      title: "Creator",
      github: "paulcsmith"
    )
  end

  def team_members
    [
      Member.new(
        fullname: "Jeremy Woertink",
        title: "Core Member",
        github: "jwoertink",
        twitter_link: "https://twitter.com/jeremywoertink"
      ),
      Member.new(
        fullname: "Matthew McGarvey",
        title: "Core Member",
        github: "matthewmcgarvey"
      ),
      Member.new(
        fullname: "Stephen Dolan",
        title: "Core Member",
        github: "stephendolan",
        twitter_link: "https://twitter.com/Stephen_Dolan"
      ),
      Member.new(
        fullname: "Edward Loveall",
        title: "Core Member",
        github: "edwardloveall"
      ),
      Member.new(
        fullname: "Michael Wagner",
        title: "Core Member",
        github: "mdwagner",
        mastodon_link: "https://mindly.social/@chocolate42"
      ),
    ] of Member
  end
end
