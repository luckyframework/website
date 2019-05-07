class Guides::JsonAndApis::ParsingJsonRequests < GuideAction
  guide_route "/json-and-apis/parsing-json-requests"

  def self.title
    "Parsing JSON Requests"
  end

  def markdown
    <<-MD
    ## Processing JSON that isn’t saved to the database

    You can use
    [`JSON.mapping`](https://crystal-lang.org/api/0.24.1/JSON.html#mapping%28_properties_%2Cstrict%3Dfalse%29-macro)
    and [`JSON.parse`](https://crystal-lang.org/api/0.24.1/JSON.html) to parse
    the response body in any way you’d like.
    MD
  end
end
