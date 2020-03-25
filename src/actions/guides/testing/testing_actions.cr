class Guides::Testing::TestingActions < GuideAction
  guide_route "/testing/testing-actions"

  def self.title
    "Testing Actions"
  end

  def markdown : String
    <<-MD
    ## HTML Actions

    ## JSON Actions

    MD
  end
end
