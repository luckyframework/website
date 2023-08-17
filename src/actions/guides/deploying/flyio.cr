class Guides::Deploying::Flyio < GuideAction
  guide_route "/deploying/flyio"

  def self.title
    "Deploying to Fly.io"
  end

  def self.external_link? : Bool
    true
  end

  def self.external_url : String
    "https://fly.io/docs/languages-and-frameworks/crystal/"
  end

  def markdown : String
    "This is an external link to [Fly.io](#{Guides::Deploying::Flyio.external_url})"
  end
end
