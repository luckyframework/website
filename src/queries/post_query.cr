class PostQuery
  POSTS = [] of BasePost

  def all
    if Lucky::Env.development?
      include_unpublished_posts
    else
      published_today_or_earlier
    end
  end

  def include_unpublished_posts
    POSTS
  end

  def published_today_or_earlier
    POSTS.select { |post| post.published_at <= Time.utc }
  end

  def find?(slug : String) : BasePost?
    POSTS.find { |post| post.slug == slug }
  end
end
