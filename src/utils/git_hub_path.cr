module GitHubPath
  extend self

  def for_file(file_path = __FILE__)
    code_path = file_path[file_path.index("/src")..-1]
    "https://github.com/luckyframework/website/blob/main#{code_path}"
  end
end
