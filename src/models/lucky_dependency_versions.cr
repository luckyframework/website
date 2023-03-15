require "semantic_version"

module LuckyDependencyVersions
  extend self

  def min_compatible_postgres_version
    SemanticVersion.new(12, 12, 0)
  end

  def min_compatible_node_version
    SemanticVersion.new(16, 5, 0)
  end
end
