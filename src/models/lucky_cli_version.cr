module LuckyCliVersion
  extend self

  def current_tag : String
    "v#{current_version}"
  end

  def current_version : String
    "0.26.0"
  end

  def compatible_crystal_version : String
    "0.36.1"
  end
end
