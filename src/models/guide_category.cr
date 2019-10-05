class GuideCategory
  getter title, guides

  def initialize(@title : String, @guides : Array(GuideAction.class))
  end

  def active?(guide_action : GuideAction.class)
    guides.includes?(guide_action)
  end
end
