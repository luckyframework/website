class Guides::Tutorial::NewResource < GuideAction
  guide_route "/tutorial/new-resource"

  def self.title
    "Creating a New Resource"
  end

  def markdown : String
    <<-MD
    ## Using the Generator CLI

    ## Running the Migration

    ## Connecting the Models
    MD
  end
end
