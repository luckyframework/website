module GitHubPath
  extend self

  def for_file(file_path = __FILE__)
    "https://github.com/luckyframework/website/blob/master#{file_path.gsub(Dir.current, "")}"
  end
end
