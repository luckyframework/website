module GitHubPath
  extend self

  def for_file(file_path = __FILE__)
    "https://github.com/paulcsmith/website-v2/blob/master#{file_path.gsub(Dir.current, "")}"
  end
end
