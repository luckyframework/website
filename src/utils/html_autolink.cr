class HtmlAutolink
  URL_REGEX = /((>|")?(http|https):\/\/)([a-z0-9-]+\.)?[a-z0-9-]+(\.[a-z]{2,6}){1,3}(\/[a-z0-9.,_\/~#&=;%+?-]*)?/i

  def initialize(@text : String)
  end

  def call
    @text.gsub(URL_REGEX) do |match|
      if already_linked?(match)
        match
      else
        %(<a href="#{match}">#{match}</a>)
      end
    end
  end

  private def already_linked?(match : String) : Bool
    [">", "\""].any? { |character| match.starts_with?(character) }
  end
end
