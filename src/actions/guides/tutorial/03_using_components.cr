class Guides::Tutorial::UsingComponents < GuideAction
  guide_route "/tutorial/components"

  def self.title
    "Using Components"
  end

  def markdown : String
    <<-MD
    ## Reusable Components

    ## Customize Components
    MD
  end
end
