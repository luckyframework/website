class Guides::GettingStarted::Installing < GuideAction
  ANCHOR_INSTALL_REQUIRED_DEPENDENCIES = "perma-install-required-dependencies"
  ANCHOR_POSTGRESQL                    = "perma-install-postgres"
  ANCHOR_PROC_MANAGER                  = "perma-install-process-manager"
  ANCHOR_NODE                          = "perma-install-node"
  guide_route "/getting-started/installing"

  def self.title
    "Installing Lucky"
  end

  def permalink_anchor_install_required_dependencies
    permalink(ANCHOR_INSTALL_REQUIRED_DEPENDENCIES)
  end

  def permalink_anchor_postgresql
    permalink(ANCHOR_POSTGRESQL)
  end

  def permalink_anchor_node
    permalink(ANCHOR_NODE)
  end

  def min_compatible_crystal_version
    LuckyCliVersion.min_compatible_crystal_version
  end

  def max_compatible_crystal_version
    LuckyCliVersion.max_compatible_crystal_version
  end

  def current_version
    LuckyCliVersion.current_version
  end

  def current_tag
    LuckyCliVersion.current_tag
  end

  def testing_html_path
    Guides::Testing::HtmlAndInteractivity.path
  end

  def flow_path
    Guides::Testing::HtmlAndInteractivity.path
  end

  def markdown : String
    ECR.render "#{__DIR__}/installing.md.ecr"
  end
end
