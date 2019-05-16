class Blog::PublishedAt < BaseComponent
  needs post : BasePost
  needs color : String = "text-grey-dark"

  def render
    span class: "font-normal text-sm #{@color} uppercase tracking-wide mt-1" do
      if @post.unpublished?
        span "unpublished", class: "mr-2 bg-orange text-white rounded px-3 py-2"
      end
      text @post.published_at.to_s("%^B %-d, %Y")
    end
  end
end
