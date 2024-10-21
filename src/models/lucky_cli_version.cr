require "semantic_version"

module LuckyCliVersion
  extend self

  def current_tag : String
    "v#{current_version}"
  end

  def current_version : SemanticVersion
    SemanticVersion.new(1, 3, 0)
  end

  def min_compatible_crystal_version : SemanticVersion
    SemanticVersion.new(1, 10, 0)
  end

  def max_compatible_crystal_version : SemanticVersion
    SemanticVersion.new(1, 14, 0)
  end
end
