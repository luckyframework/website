class Guides::Tutorial::OperationsFactories < GuideAction
  guide_route "/tutorial/operations-and-factories"

  def self.title
    "Operations and Factories"
  end

  def markdown : String
    <<-MD
    ## Title

    ## Title
    MD
  end
end
