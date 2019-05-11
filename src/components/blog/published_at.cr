class Blog::PublishedAt < BaseComponent
  needs published_at : Time?
  needs color : String = "text-grey-dark"

  def render
    published_at = @published_at

    span class: "font-normal text-sm #{@color} uppercase tracking-wide mt-1" do
      if published_at
        text "Published "
        time_ago_in_words published_at
      else
        text "Unpublished"
      end
    end
  end
end
