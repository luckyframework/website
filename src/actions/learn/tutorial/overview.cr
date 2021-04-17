class Learn::Tutorial::Overview < GuideAction
  guide_route "/tutorial/overview"

  def self.title
    "Tutorial Overview"
  end

  def markdown : String
    <<-MD
    ## Our First Lucky Application

    Coming soon...
    MD
  end
end
