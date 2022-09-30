require "semantic_version"

module LuckyCliVersion
  extend self

  def current_tag : String
    "v#{current_version}"
  end

  def current_version : SemanticVersion
    SemanticVersion.new(1, 0, 0, "rc1")
  end

  def min_compatible_crystal_version : SemanticVersion
    SemanticVersion.new(1, 4, 0)
  end

  def max_compatible_crystal_version : SemanticVersion
    SemanticVersion.new(1, 6, 0)
  end
end
