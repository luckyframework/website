class Guides::Tutorial::Queries < GuideAction
  guide_route "/tutorial/queries"

  def self.title
    "Writing Custom Queries"
  end

  def markdown : String
    <<-MD
    ## Title

    ## Title
    MD
  end
end
