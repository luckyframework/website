class Guides::Tutorial::Design < GuideAction
  guide_route "/tutorial/design"

  def self.title
    "New Home page and some Design"
  end

  def markdown : String
    <<-MD
    ## Swapping out the HomePage

    ## Updating the Layout

    ## Adding a CSS framework
    MD
  end
end
